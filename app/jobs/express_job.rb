class ExpressJob < ApplicationJob
    queue_as :default
    BLACKLIST = Set.new(["header", "footer", "a", "code", "template", "text", "form", "link", "script", "img", "iframe", "icon", "comment", "button", "input", "head", "meta", "style"])

  
    def perform(request, bio_payload, listing_payload, listing_type="url", user_prompt="Write a cover letter for the job listing that uses the resume as support.")
        # debugger
        user_prompt = "Write a cover letter for the job listing that uses the resume as support." if user_prompt.empty?
        # generate user bio
        @bio = text_to_user_bio(bio_payload)
        
        if !@bio
            return request.complete!(false, nil, ["Error while generating bio."])
        end

        # generate listing
        begin
            if listing_type == "url"
              listing_obj = http_to_listing(listing_payload)
            elsif listing_type == "text"
              listing_obj = text_to_listing(listing_payload)
            end
            @listing = Listing.new(listing_obj)
            @profile = Profile.new(JSON.parse(@bio))
      
        rescue => e
            request.complete!(false, nil, [e.to_s])
        end


        # generate letter

        OpenAI.configure do |config|
            config.access_token = ENV["OPENAI"]
        end
        resume = JSON.parse(
            @profile.to_json(except: [:id, :title]).gsub("\r", "")
        )
        resume["first_name"] = "WriteWise"
        resume["last_name"] = "User"
        
        client = OpenAI::Client.new 
        response = client.chat(
            parameters: {
            model: "gpt-3.5-turbo",
            messages: [
                {role: "system", content:"Write cover 2-3 paragraph cover letter as job candidate. Do not include address, phone number, or email. Include details about education and work experience from the users resume. Don't use the education or any phrase like \"5+ years of experience\" that is mentioned in the Job-Listing. {Job-Listing: #{JSON.parse(@listing.to_json(except: :id).gsub("\r", ""))}\n
                Resume: #{resume}}"},
                {role: "user", content: "#{user_prompt}"
                }
            ],
            temperature: 1.3
            # max_tokens: 10000
            }
        )
           
        begin
            @message = response["choices"][0]["message"]["content"]
            @letter = TempLetter.new(profile: @profile.to_json, listing: @listing.to_json, body: @message)

            if @letter.save
                #success
                request.complete!(true, @letter.secure_id, @message)
            else
                #failure
                request.complete!(false, nil, @letter.errors.full_messages.to_s)
            end
        rescue
            @message = response.to_json
            request.complete!(false, nil, @message)
        end
  
    end

    
  
    def text_to_user_bio(text)
  
        OpenAI.configure do |config|
            config.access_token = ENV["OPENAI"]
        end
        client = OpenAI::Client.new
  
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo",
                messages: [
                    {role: "system", content:"Return JSON with values that summarize this document. Use exactly these keys: {\"aboutme\": \"string\", \"skills\": str[], \"education\": str[], \"projects\": str[], \"experience\": str[]}. Your response must be only valid JSON with a flat shape. \"aboutme\" should be at least 2 sentences long. If \"skills\" would be empty, use generic professional skills such as Time Management, Communication, Teamwork, Problem Solving"},
                    {role: "user", content: text}
                ],
                response_format: {type: "json_object"},
                temperature: 1.4
                # max_tokens: 10000
            }
        )
        # debugger
        begin
          message = response["choices"][0]["message"]["content"]
          return message
        rescue
          return false
        end
    end

    def text_to_listing(text) # Turns text into a job-listing hash

        OpenAI.configure do |config|
            config.access_token = ENV["OPENAI"]
        end
        client = OpenAI::Client.new
        
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo",
                messages: [
                    {role: "system", content:"Summarize. Respond with only valid JSON with exact keys: {\"company\": \"string\", \"job_title\": \"string\", \"job_description\": \"string\", \"requirements\": str[], \"benefits\": str[]}. Ensure there is no trailing comma after the last value."},
                    {role: "user", content: text}
                ],
                response_format: {type: "json_object"},
                temperature: 0.9
                # max_tokens: 10000
            }
        )
  
        begin
            message = response["choices"][0]["message"]["content"]
            output = JSON.parse(message)
            logger.info("Listing Parsed on First Try")
        rescue JSON::ParserError
            origin = message.dup
            message.insert(-2, "''") # Fills empty benefits value
            message.gsub!("'", "\"") # Replace single quotes with double quotes
            begin 
                output = JSON.parse(message)
                logger.info("Listing Parsed on Second Try")
            rescue JSON::ParserError
                output = JSON.parse(origin[0..-4]+"''}") # Removes trailing comma from JSON string
                logger.info("Listing Parsed on Third Try")
            end

        rescue
            return false
        end
        return output
    end
  
    def http_to_listing(response_body) #turns http response into minimized string ready to send to GPT
  
        raw_doc = Nokogiri::HTML(response_body)
        memo = raw_doc.search("main")
        document = memo.empty? ? raw_doc.search("body")[0] : memo[0]
  
        BLACKLIST.each{ |tag| document.search(tag).remove }
        document.traverse{ |node| 
            node.element? && node.attributes.each_key{|name| node.remove_attribute(name)}
        }
        unless raw_doc.search("title").empty?
            document.prepend_child(raw_doc.search("title")[0])
        end
        
        trimmed_doc = document.to_s
        trimmed_doc.gsub!(/\n/, "\s\s")
        trimmed_doc.gsub!("  ", "")
        trimmed_doc.gsub!("<div>", "")
        trimmed_doc.gsub!("</div>", "")    
        return text_to_listing(trimmed_doc)
    end
end
  