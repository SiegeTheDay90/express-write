class ApplicationController < ActionController::Base
    include ActionController::RequestForgeryProtection
    protect_from_forgery with: :exception
    rescue_from StandardError, with: :unhandled_error
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_exception
    helper_method :current_user

    before_action :snake_case_params, :attach_authenticity_token

    def stress_test
        stress = params["amount"] || 10

        stress.times do |i|
            StressTestJob.perform_later(i)
        end

        render plain: "Stressing with #{stress} jobs. Check server logs."
    end

    def show
        require_logged_out()
    end
    
    def current_user
        @current_user ||= User.includes(:listings, :letters, :profiles).find_by(session_token: session['_clhelper_session'])
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
        redirect_to user_url(current_user) if current_user
    end

    def test

        url = ""

        if params["text"].split("/").include?("docs.google.com")
            id = params["text"].split("/")[-2]
            url = "https://drive.google.com/uc?export=download&id=#{id}"
        else 
            url = params["text"]
        end

        debugger

        docx = URI.open(url)
        text = helpers.docx_to_text(docx)
        debugger
        puts "OK"
        render plain: text
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


end
