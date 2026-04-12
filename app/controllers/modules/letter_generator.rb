module LetterGenerator  
  
  def get_response(req)
    begin
      return http_response = HTTP.headers('User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36').get(params['listing'])
    rescue StandardError => e
      render_error(e)
    end
  end
  
  def render_error(e, id_num)
    errors = ["Error: #{e.to_s}\nConsider copy/pasting the listing as plain text."]
    BugReport.create!(
      body: "Error: #{e.to_s}",
      user_agent: "LettersController#express"
    )
    render json: { ok: false, errors:, id: id_num } and return
  end
  
  def render_http_error(http_response, id_num)
    errors = ['Please check the url and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text.']
    render json: { ok: false, errors: errors, id: id_num } and return
  end
  
  def process_resume_file(resume_file)
    if resume_file.content_type == "application/pdf"
      # PDF
      return helpers.pdf_to_text(resume_file.to_io)
    else
      # DOC(x)
      return helpers.docx_to_text(resume_file.to_io)
    end
  end
  
  def get_listing_payload(params, req)
    if params['listing_type'] == 'url'
      begin
        http_response = get_response(req)
        if http_response.status != 200
          req.update!(ok: false, complete: true, messages: http_response.status.to_s)
          render_http_error(http_response, req.id) and return
        else
          return http_response.body.to_s
        end
      rescue StandardError => e
        req.update!(ok: false, complete: true, messages: e.to_s)
        render_error(e, req.id) and return
      end
    else
      return params['listing']
    end
  end
  
  def get_resume_payload(params, req)
    if params["resume_upload_type"] == "file"
      begin
        return process_resume_file(params['resume'])
      rescue StandardError => e
        req.update!(ok: false, complete: true, messages: e.to_s)
        render_error(e, req.id) and return
      end
    else # Just plain text
      return params['text']
    end
  end
  
  def get_custom_tone_payload(params, req)
    return nil unless custom_tone = params["custom_tone"]
    if custom_tone.is_a?(String)
      return custom_tone
    elsif custom_tone
      begin
        if custom_tone.content_type == "application/pdf"
          return helpers.pdf_to_text(custom_tone.to_io)
        else
          return helpers.docx_to_text(custom_tone.to_io)
        end
      rescue NoMethodError => e
        message = "The file was corrupt or incompatible. Please try plain text."      
        req.update!(ok: false, complete: true, messages: e.to_s)
        render_error(message, req.id) and return
      rescue StandardError => e
        req.update!(ok: false, complete: true, messages: e.to_s)
        render_error(e, req.id) and return
      end
    end
  end
end
