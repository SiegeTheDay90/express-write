class GenerateBioJob < ApplicationJob
  queue_as :default

  def perform(request, current_user, payload)
    bio = text_to_user_bio(payload)
    
    
    if !bio
      request.complete!(false, nil, "Error while generating bio.")
    else
      request.complete!(true, current_user.id, bio)
    end

  end

  def text_to_user_bio(text)

      OpenAI.configure do |config|
          config.access_token = ENV["OPENAI"]
      end
      client = OpenAI::Client.new
      
      response = client.chat(
          parameters: {
              model: "gpt-3.5-turbo-16k",
              messages: [
                  {role: "system", content:"Return JSON with values that summarize this document. Use exactly these keys: {'aboutme': 'string', 'skills': str[], 'education': str[], 'projects': str[], 'experience': str[]}. Your response must be only valid JSON."},
                  {role: "user", content: text[0]}
              ],
              top_p: 0.2
          }
      )
      begin
        message = response["choices"][0]["message"]["content"]
        return message
      rescue
        return false
      end
  end
end
