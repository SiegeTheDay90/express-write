# frozen_string_literal: true

class LettersController < ApplicationController
  def express
    
    req = Request.create!(resource_type: 'temp_letter', session_id: @session.session_id)

    # Listing to Text Payload
    if params['listing_type'] == 'url'
      begin
        http_response = HTTP.headers('User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36').get(params['listing'])
      rescue StandardError => e
        BugReport.create!(
          body: "Error: #{e.to_s}",
          user_agent: "LettersController#express"
        )
        errors = ["Error: #{e.to_s}\nConsider copy/pasting the listing as plain text."]
        req.update!(ok: false, complete: true, messages: errors)
        render json: { ok: false, errors:, id: req.id } and return
      end

      if http_response.status >= 400
        errors = ['The link resulted in a 400+ error. Please check the url and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text.']
        req.update!(ok: false, complete: true, messages: errors)
        render json: { ok: false, errors:, id: req.id } and return
      elsif http_response.status >= 300
        errors = ['The link resulted in a redirect. Please use a direct link and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text.']
        req.update!(ok: false, complete: true, messages: errors)
        render json: { ok: false, errors:, id: req.id } and return
      else
        debugger
        @listing_payload = http_response.body.to_s
      end
    else
      @listing_payload = params['listing']
    end

    # THIS NEEDS A REWRITE
    # Resume to Text Payload 
    if params["resume_upload_type"] == "file"
      begin
        @resume = params['resume']        
        if @resume.content_type == "application/pdf"
          # PDF
          @resume = helpers.pdf_to_text(@resume.to_io)
        else
          # DOC(x)
          @resume = helpers.docx_to_text(@resume.to_io)
        end
      rescue StandardError => e
        errors = ["Error: #{e.to_s}"]
        BugReport.create!(
          body: e.to_s,
          user_agent: "Letters#express:54"
        )        
        req.update!(ok: false, complete: true, messages: errors)
        render json: { ok: false, errors:, id: req.id } and return
      end
    else # Just plain text
      @resume = params['text']
    end

    
    


    user_prompt = params['prompt']
    if params["tone_select"]
      # Predefined tone
      tone = params['tone_select']
    else
      @custom_tone = true
      begin
        if params["tone"].content_type == "application/pdf"
          tone = helpers.pdf_to_text(params["tone"].to_io)
        else
          tone = helpers.docx_to_text(params["tone"].to_io)
        end
      rescue StandardError => e
        errors = ["Error: #{e.to_s}"]
        BugReport.create!(
          body: e.to_s,
          user_agent: "Letters#express:82"
          )        
          req.update!(ok: false, complete: true, messages: errors)
          render json: { ok: false, errors:, id: req.id } and return
      end
    end
    ExpressJob.perform_later(req, @resume, @listing_payload, params['listing_type'], user_prompt, tone, @custom_tone)
    render json: { ok: true, message: 'Letter Started', id: req.id }
  end

  def temp
    @letter = TempLetter.find_by(secure_id: params['id'])
  end

  # def helpful
  #     @letter = Letter.find_by(id: params[:id])
  #     redirect_to users_url(current_user) and return unless @letter

  #     @letter.helpful = params["status"]
  #     if @letter.save
  #         render plain: "Success", status: 200
  #     else
  #         render plain: "Failure", status: 418
  #     end
  # end

  # def update
  #     @letter = Letter.find(params["id"])
  #     @letter.update(content: params["letter"]["content"])
  #     @letter.body = params["letter"]["content"].gsub("<br>", "\n").gsub("&nbsp;", "").gsub(/<[^>]*>/, "")
  #     flash.now["messages"] = ["Letter saved!"]
  #     render :show
  # end
end
