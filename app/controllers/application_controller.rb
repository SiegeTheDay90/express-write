class ApplicationController < ActionController::Base
    include ActionController::RequestForgeryProtection
    protect_from_forgery with: :exception
    rescue_from StandardError, with: :unhandled_error
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_exception
    before_action :snake_case_params, :attach_authenticity_token

    def valid_url?
        if params["url"][0..3] != "http"
            params["url"] = "https://"+params["url"]
        end
        begin
            response = URI.open(params["url"])
            if(response.status[0].to_i < 300)
                render json: {ok: true}
            else
                render json: {ok: false, status: response.status }
            end
        rescue OpenURI::HTTPError => e
            render json: {ok: false, status: e}
        rescue => e
            render json: {ok: false, status: e}
        end
    end
    
    
    def splash
        render layout: 'empty'
    end
    
    
    def test
        OpenAI.configure do |config|
            config.access_token = ENV["GPT4"]
        end
        client = OpenAI::Client.new
        
        
        response = client.chat(
            parameters: {
                model: "gpt-4",
                messages: [
                    {role: "system", content: "You are a helpful letter-writing assistant."},
                    {role: "user", content: "Write a cover letter for a Support Engineer role at GitHub."}
                ],
                # response_format: {type: "json_object"},
                temperature: 1.1,
                max_tokens: 8000
            }
            )
            
            begin
                message = response
                render json: message
            rescue => e
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
            headers['X-CSRF-Token'] = masked_authenticity_token(session)
        end
        
        def handle_csrf_exception
            render json: {errors: ["Invalid Authenticity Token"]}, status: 422
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
                    render json: {error: @message}
                end
            end
            
        end
        
    
        def stress_test
            stress = params["amount"] || 10
    
            stress.times do |i|
                StressTestJob.perform_later(i)
            end
    
            render plain: "Stressing with #{stress} jobs. Check server logs."
        end
        
        
    end
    