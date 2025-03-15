# frozen_string_literal: true
require "google/cloud/firestore"
class ApplicationController < ActionController::Base
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :exception
  rescue_from StandardError, with: :unhandled_error
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_exception
  before_action :snake_case_params, :attach_authenticity_token, :track_session
  helper_method :days_since_last_error, :requests_this_week

  def csrf
    headers['X-CSRF-Token'] = masked_authenticity_token
    render json: {token: masked_authenticity_token}
  end

  def stats
    project_id = "hitcounter-c6795"
    firestore = Google::Cloud::Firestore.new project_id: project_id, keyfile: Rails.env.production? ? {
      "type" => "service_account",
      "project_id" => "hitcounter-c6795",
      "private_key_id" => "d01fd1332de21305d7199e44c6ea25694c114dd7",
      "private_key" => "-----BEGIN PRIVATE KEY-----\n#{ENV["FIRESTORE_KEY"].gsub("@", "\n")}\n-----END PRIVATE KEY-----\n",
      "client_email" => "firebase-adminsdk-arcz5@hitcounter-c6795.iam.gserviceaccount.com",
      "client_id" => "107163233339707064765",
      "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
      "token_uri" => "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-arcz5%40hitcounter-c6795.iam.gserviceaccount.com",
      "universe_domain" => "googleapis.com"
    } : "./keyfile.json"

    doc = firestore.doc "Hits/write-wise-splash"
    data = doc.get.fields.to_a
              .sort_by{|entry| Date.strptime(entry[0].to_s, '%m-%d-%Y')}
    weekly = data.group_by{|entry| Date.strptime(entry[0].to_s, '%m-%d-%Y').cweek}
    
    @weekly_labels ||= []
    @weekly_values ||= []
    weekly = weekly.each do |cweek, data|
      date = Date.new(2025) + (cweek-1).week

      @weekly_labels << date.to_s
      @weekly_values << data.inject(0){|acc, datum| acc + datum[1]}

    end

    @labels ||= []
    @values ||= []
    
    data.each do |entry|
      @labels << entry[0].to_s # Date String "1-1-2024"
      @values << entry[1].to_i # Number
    end
  end

  def valid_url?
    params['url'] = "https://#{params['url']}" if params['url'][0..3] != 'http'
    begin
      response = URI.open(params['url'])
      if response.status[0].to_i < 300
        render json: { ok: true, status: 'WOOF' }
      else
        render json: { ok: false, status: response.status }
      end
    rescue OpenURI::HTTPError => e
      render json: { ok: false, status: e }
    rescue StandardError => e
      render json: { ok: false, status: e }
    end
  end

  def splash
    render layout: 'empty'
  end

  def test
    OpenAI.configure do |config|
      config.access_token = ENV['GPT4']
    end
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          { role: 'system', content: 'You are a helpful letter-writing assistant.' },
          { role: 'user', content: 'Write a cover letter for a Support Engineer role at GitHub.' }
        ],
        # response_format: {type: "json_object"},
        temperature: 1.1,
        max_tokens: 8000
      }
    )

    begin
      message = response
      render json: message
    rescue StandardError => e
      render plain: "Try Again.\nError Occurred: #{e}: #{e.message}"
    end
  end

  def err_test
    raise "Test Error: #{Date.today}"
  end

  private

  def snake_case_params
    params.deep_transform_keys!(&:underscore)
  end

  def attach_authenticity_token
    headers['X-CSRF-Token'] = masked_authenticity_token
  end

  def handle_csrf_exception
    render json: { errors: ['Invalid Authenticity Token'] }, status: 422
  end

  def unhandled_error(error)
    @stack = Rails::BacktraceCleaner.new.clean(error.backtrace)
    logger.error "\n#{@message}:\n\t#{@stack.join("\n\t")}\n"

    respond_to do |format|
      format.html do
        @error = error
        render '/utils/500'
      end

      format.json do
        @message = "#{error.class} - #{error.message}"
        render json: { error: @message }
      end
    end
  end

  def stress_test
    stress = params['amount'] || 10

    stres
    s.times do |i|
      StressTestJob.perform_later(i)
    end

    render plain: "Stressing with #{stress} jobs. Check server logs."
  end

  def days_since_last_error
    (Date.today - (Request.select(:created_at).where.not(ok: true)&.order(created_at: :desc).limit(1)[0]&.created_at&.to_date || Date.today)).to_i
  end

  def requests_this_week
    Request.where(created_at: Date.today-1.week..Date.today)
  end

  def track_session
    @session = Session.find_by(session_id: session["session_id"])
    if @session
      @session.update!(hits: @session.hits+1)
    elsif session.loaded?
      # create session
      @session = Session.create!(
        session_id: session["session_id"],
        ip_address: request.remote_ip,
        hits: 1,
        user_agent: request.user_agent
      )
    end
  end
end
