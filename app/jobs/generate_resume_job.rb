# frozen_string_literal: true

class GenerateResumeJob < ApplicationJob
  queue_as :default

  def perform(request, text)
    resume = text_to_resume(text)

    if !resume
      request.complete!(false, nil, ['Error while generating resume.'])
    elsif resume.include?("-@-ErrorString-@-")
      request.complete!(false, nil, resume.gsub("-@-ErrorString-@-", ""))
    else
      request.complete!(true, nil, resume)
    end
  end

 
 
 
  def text_to_resume(text)
    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system',
            content: 'Covert input to JSON with values that summarize this document. Use exactly this shape, keys, and data types: {
              personal: {
                  firstName: '',
                  lastName: '',
                  profession: '',
                  phoneNumber: '',
                  email: '',
                  website: ''
              },
              work: [{
                  companyName: '',
                  jobTitle: '',
                  city: '',
                  location: '',
                  from: '',
                  to: '',
                  description: '',
                  current: boolean
                }],
              education: [{
                  institutionName: '',
                  fieldOfStudy: '',
                  degreeType: '',
                  city: '',
                  location: '',
                  to: '',
                  description: '',
                  current: boolean
                }],
              skills: str[],
          }. If "skills" array would be empty, use two generic professional skills such as Time Management, Communication, Teamwork, or Problem Solving' },
          { role: 'user', content: text }
        ],
        response_format: { type: 'json_object' },
        temperature: 1.3,
        max_tokens: 4096
      }
    )
    # response = {'choices' => [{'message' => {'content' => '{Incomplete JSON STRING'}}]}
    begin
      JSON.parse(response['choices'][0]['message']['content'])
      return response['choices'][0]['message']['content']
    rescue JSON::ParserError
      BugReport.create!(
        body: "Invalid JSON: #{response['choices'][0]['message']['content']}",
        user_agent: "GenerateResumeJob"
      )
      return "-@-ErrorString-@-Invalid JSON: #{response['choices'][0]['message']['content']}"
    rescue StandardError
      return fasle
    end
  end
end
