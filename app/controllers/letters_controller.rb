# frozen_string_literal: true
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

class LettersController < ApplicationController
  include LetterGenerator
  def express
    tones = [:admiration, :confident, :humorous, :basic]

    req = Request.create!(resource_type: 'temp_letter', session_id: @session.session_id, resource_id: SecureRandom.urlsafe_base64, count: 0)

    # Listing to Text Payload
    @listing_payload = get_listing_payload(params, req)
    return if performed?

    # Resume to Text Payload 
    @resume = get_resume_payload(params, req)
    return if performed?
    
    @custom_tone = get_custom_tone_payload(params, req)
    return if performed?

    @user_prompt = params['prompt'] || ""
    
    if @custom_tone
      tones.pop
      ExpressJob.perform_later(req.id, @resume, @listing_payload, params['listing_type'], @user_prompt, @custom_tone)
    end
    for tone in tones do
      ExpressJob.perform_later(req.id, @resume, @listing_payload, params['listing_type'], @user_prompt, tone)
    end

    render json: { ok: true, message: 'Letter Started', id: req.id } and return
  end
  def update
    @letter = TempLetter.where(secure_id: params['secure_id']).find_by(tone: params[:tone])

    begin
      if @letter
        @letter.update!(body: params['body'])
        render json: { ok: true, message: 'Letter Updated' }
      else
        render json: { ok: false, message: 'Letter Not Found' }, status: 404
      end
    rescue StandardError => e
      render json: { ok: false, message: "Error: #{e.to_s}" }, status: 500
    end
  end

  def show
    @letters = TempLetter.where(secure_id: params['secure_id']).order(:id)
    @editor_letter = @letters.first || TempLetter.new
  end

  def index
    render :show
  end
  def temp
    @letter = TempLetter.find_by(secure_id: params['secure_id'])
  end
  def destroy
    @letter = TempLetter.where(secure_id: params['secure_id']).find_by(tone: params[:tone])

    if @letter
      @letter.destroy
      render json: { ok: true, message: 'Letter Deleted' }
    else
      render json: { ok: false, message: 'Letter Not Found' }, status: 404
    end
  end
  # def index
  #   # @letters = TempLetter.all
  #   render :show
  # end

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
