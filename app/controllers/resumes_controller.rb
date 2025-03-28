# frozen_string_literal: true

class ResumesController < ApplicationController
  def create
    content_type = request.headers['Content-Type']
    raise TypeError.new('Content-Type must be application/pdf or application/vnd.openxmlformats-officedocument.wordprocessingml.document') unless ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].include?(content_type)
    req = Request.create!(resource_type: 'resume', session_id: @session.session_id)
    if content_type == "application/pdf"
      text = helpers.pdf_to_text(request.body)
    else
      text = helpers.docx_to_text(request.body)
    end
    
    GenerateResumeJob.perform_later(req, text)

    render json: {ok: true, status: 'Resume In Progress', id: req.id}
  end

  def suggest_bullets
    description = params['description']
    prompt = nil
    item = params['item']
    tense = item['current'] ? 'present' : 'past'

    if params['description']
      prompt = "Update bullet points to fix grammar and professionalism. If possible, the points should include a metric that supports bullet point. Separate bullets with a \\n character. Write bullets in #{tense} tense. Leave out the 'I' in first person sentences."
    else
      prompt = "Write 2-3 new-line separated sentences that could be used as job description bullet points for a resume. If possible, the points should include a metric that supports proficiency at that type of job. Separate bullets with a \\n character. Write bullets in #{tense} tense. Leave out the 'I' in first person sentences."
    end

    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          { role: 'system', content: prompt },
          { role: 'user',
            content: description ? "Update these Bullets: #{description.split("\n").join(',')} for the Job: #{item}" : "Suggest bullet points for this Job: #{item}" }
        ],
        temperature: 1.1
      }
    )

    begin
      message = response['choices'][0]['message']['content'].gsub(/\ ?-\ /, '')
      render plain: message
    rescue StandardError => e
      render plain: "Try Again.\nError Occurred: #{e}: #{e.message}"
    end
  end
end
