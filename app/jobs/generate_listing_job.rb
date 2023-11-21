class GenerateListingJob < ApplicationJob
  queue_as :default
  BLACKLIST = Set.new(["header", "footer", "a", "code", "template", "text", "form", "link", "script", "img", "iframe", "icon", "comment", "button", "input", "head", "meta", "style"])
  
  def perform(request, type, payload, current_user)

    begin
      if type == "http"
        listing_obj = http_to_listing(payload)
      elsif type == "text"
        listing_obj = text_to_listing(payload)
      end

      @listing = Listing.new(**listing_obj, user_id: current_user.id)
      
      if @listing.save
          request.complete!(true, @listing.id)
      else
          request.complete!(false, nil, @listing.errors.full_messages)  
      end 

    rescue => e
      request.complete!(false, nil, e.to_s)
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
                  {role: "system", content:"Summarize. Respond with only valid JSON with exact keys: {'company': 'string', 'job_title': 'string', 'job_description': 'string', 'requirements': str[], 'benefits': str[]}. Ensure there is no trailing comma after the last value."},
                  {role: "user", content: text}
              ],
              temperature: 1.1,
              max_tokens: 10000
          }
      )

      begin
          message = response["choices"][0]["message"]["content"]
          output = JSON.parse(message)
          logger.info("Listing Parsed on First Try")
      rescue JSON::ParserError
          output = JSON.parse(message[0..-4]+"}") # Removes trailing comma from JSON string
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
