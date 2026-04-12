# frozen_string_literal: true
require_relative './modules/letter_generator'
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
