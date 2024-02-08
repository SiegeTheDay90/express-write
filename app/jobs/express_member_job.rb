class ExpressMemberJob < ApplicationJob
  queue_as :default
  BLACKLIST = Set.new(["header", "footer", "a", "code", "template", "text", "form", "link", "script", "img", "iframe", "icon", "comment", "button", "input", "head", "meta", "style"])

  def perform(request, user_id, listing_payload, listing_type="url")
    user = User.find(user_id)
    @profile = Profile.find(user.active_profile)
    # generate listing
    begin
      if listing_type == "url"
        listing_obj = http_to_listing(listing_payload)
      elsif listing_type == "text"
        listing_obj = text_to_listing(listing_payload)
      end

      @listing = Listing.new(listing_obj)
      @listing.user_id = user_id
      @listing.save!

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
    resume["first_name"] = user.first_name
    resume["last_name"] = user.last_name
    
    client = OpenAI::Client.new 
    response = client.chat(
      parameters: {
      model: "gpt-3.5-turbo-16k",
      messages: [
        {role: "system", content:"Write cover 2-3 paragraph cover letter as job candidate. Include details about education and work experience from the users resume. Don't use the education or any phrase like \"5+ years of experience\" that is mentioned in the Job-Listing."},
        {role: "user", content: "Job-Listing: #{JSON.parse(@listing.to_json(except: :id).gsub("\r", ""))}\n
        Resume: #{resume}"
        }
      ],
      temperature: 1.3,
      max_tokens: 10000
      }
    )
          
    begin
        @message = response["choices"][0]["message"]["content"]
        @letter = Letter.new(user_id: user_id, listing: @listing, body: @message)

        if @letter.save
            #success
            request.complete!(true, @letter.id, @message)
        else
            #failure
            request.complete!(false, nil, @letter.errors.full_messages.to_s)
        end
    rescue
        @message = response.to_json
        request.complete!(false, nil, @message)
    end

  end

  def text_to_listing(text) # Turns text into a job-listing hash

    OpenAI.configure do |config|
        config.access_token = ENV["OPENAI"]
    end
    client = OpenAI::Client.new
    
    response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo-16k",
            messages: [
                {role: "system", content:"Summarize. Respond with only valid JSON with exact keys: {\"company\": \"string\", \"job_title\": \"string\", \"job_description\": \"string\", \"requirements\": str[], \"benefits\": str[]}. Ensure there is no trailing comma after the last value."},
                {role: "user", content: text}
            ],
            temperature: 0.9,
            max_tokens: 10000
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
