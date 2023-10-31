class ApplicationController < ActionController::Base
    include ActionController::RequestForgeryProtection
    protect_from_forgery with: :exception
    rescue_from StandardError, with: :unhandled_error
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_exception
    helper_method :current_user
    before_action :require_logged_out, only: :show

    before_action :snake_case_params, :attach_authenticity_token

    def current_user
        @current_user ||= User.includes(:listings, :letters).find_by(session_token: session['_clhelper_session'])
    end
    
    def express
        render :express
    end
      
    def login!(user)
        session['_clhelper_session'] = user.reset_session_token!
    end
    
    def logout!
        session['_clhelper_session'] = nil
        current_user.reset_session_token!
        @current_user = nil
    end
    
    def require_logged_in
        redirect_to root_url unless current_user
    end

    def require_logged_out
        redirect_to user_listings_url(current_user) if current_user
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
        if request.accepts.first.html?
            raise error
        else
            @message = "#{error.class} - #{error.message}"
            @stack = Rails::BacktraceCleaner.new.clean(error.backtrace)
            render 'api/errors/internal_server_error', status: :internal_server_error
            logger.error "\n#{@message}:\n\t#{@stack.join("\n\t")}\n"
        end
    end

    def user_params
        params.require(:user).permit(:email, :first_name, :last_name, :password)
    end

    def session_params
        params.require(:session).permit(:credential, :password)
    end
    
    def listing_params
        lp = params.require(:listing).permit(:company, :job_title, :job_description, :requirements, :benefits)
        lp[:requirements] = lp[:requirements].split("\n")
        lp[:benefits] = lp[:benefits].split("\n")
        return lp
    end

    def test
        @listing = Listing.third_to_last
        return redirect_to edit_user_url(current_user) unless @listing

         OpenAI.configure do |config|
            config.access_token = ENV["OPENAI"]
        end
        client = OpenAI::Client.new
        
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo-16k",
                messages: [
                    {role: "system", content:"Write cover 2-3 paragraph cover letter as job candidate."},
                    {role: "user", content: "Job: #{JSON.parse(@listing.to_json(except: :id).gsub("\r", ""))}\nCandidate: #{JSON.parse(@listing.user.to_json(except: :id).gsub("\r", ""))}"}
                ],
                max_tokens: 15200,
                temperature: 1.1
                # top_p: 0.25
            }
        )
        # debugger
        @message = response["choices"][0]["message"]["content"]
        render plain: @message
        # @letter = Letter.new(body: @message, listing_id: @listing.id, user_id: current_user.id)
    end

end
