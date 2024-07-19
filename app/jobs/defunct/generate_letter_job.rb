# frozen_string_literal: true

class GenerateLetterJob < ApplicationJob
  queue_as :default

  # Generate a letter for `listing.id` by `current_user`
  def perform(request, listing, user)
    unless user.profile
      return request.complete!(false, nil, ['You must have an active resume profile to generate a letter.'])
    end

    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    resume = JSON.parse(
      user.profile.to_json(except: %i[id title]).gsub("\r", '')
    )
    resume['first_name'] = user.first_name
    resume['last_name'] = user.last_name
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system',
            content: "Write cover 2-3 paragraph cover letter as job candidate. Include details about education and work experience from the users resume. Don't use the education or any phrase like \"5+ years of experience\" that is mentioned in the Job-Listing." },
          { role: 'user', content: "Job-Listing: #{JSON.parse(listing.to_json(except: :id).gsub("\r", ''))}\n
              Resume: #{resume}" }
        ],
        response_format: { type: 'json_object' },
        temperature: 1.3,
        max_tokens: 10_000
      }
    )
    begin
      @message = response['choices'][0]['message']['content']
      @letter = Letter.new(body: @message, listing_id: listing.id, user_id: user.id)
      @letter.content.body = @letter.body.gsub("\n", '<br>')
      if @letter.save
        # success
        request.complete!(true, @letter.id, @letter.content.body)
      else
        # failure
        request.complete!(false, nil, @letter.errors.full_messages)
      end
    rescue StandardError
      @message = response.to_json
      request.complete!(false, nil, [@message])
    end
  end
end
