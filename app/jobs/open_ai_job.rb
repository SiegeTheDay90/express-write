class OpenAiJob < ApplicationJob
  queue_as :default

  
  def perform(request, listing, current_user)
    OpenAI.configure do |config|
      config.access_token = ENV["OPENAI"]
    end
    client = OpenAI::Client.new
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
              {role: "system", content:"Write cover 2-3 paragraph cover letter as job candidate."},
              {role: "user", content: "Job: #{JSON.parse(listing.to_json(except: :id).gsub("\r", ""))}\nCandidate: #{JSON.parse(listing.user.to_json(except: :id).gsub("\r", ""))}"}
          ],
          temperature: 1.1,
          max_tokens: 3200
        }
      )
      begin
        @message = response["choices"][0]["message"]["content"]
        @letter = Letter.new(body: @message, listing_id: listing.id, user_id: current_user.id)
        @letter.content.body = @letter.body.gsub("\n", "<br>")
        if @letter.save
            #success
            request.complete!(true)
        else
            #failure
            request.complete!(false, @letter.errors.full_messages.to_s)
        end
      rescue
        @message = response["choices"][0]["message"]
        request.complete!(false, @message)
      end
  end
end
