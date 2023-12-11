class SessionsController < ApplicationController
    before_action :require_logged_out, only: [:new, :linkedin, :create]
    before_action :require_logged_in, only: :destroy
    

    def demo
      @user = User.create_with(password:"password", first_name:"Demo", last_name:"User").find_or_create_by(email:"demo@user.io")
      login!(@user)
      redirect_to user_path(@user)
    end

    def linkedin
        code = params["code"]
        unless code
            render plain: "Unauthorized", status: 401
        end
        response = HTTP.post("https://www.linkedin.com/oauth/v2/accessToken", params: {grant_type: "authorization_code", code: code, client_id: ENV["OAUTH_CLIENT_ID"], client_secret: ENV["OAUTH_CLIENT_SECRET"], redirect_uri: ENV["OAUTH_CALLBACK_URI"]})
        access_token = JSON.parse(response.body.to_param)["access_token"]
        
        response = HTTP.auth("Bearer #{access_token}").get("https://api.linkedin.com/v2/userinfo")
        info = JSON.parse(response.body.to_param)
        is_returning_user = User.exists?(uid: info["sub"])
        @user = User.omni_authorize(info)
        if @user
            login!(@user)
            flash["messages"] = "Successfully Logged In as #{@user.first_name}"
            if !is_returning_user
              UserMailer.with(user: @user).welcome_email.deliver_now
            end
            redirect_to user_path(@user)
        else
            @user = nil
            flash.now["errors"] = "Could not Login with LinkedIn"
            render :new
        end
    end

    def create
      @user = User.find_by_credentials(session_params[:credential].downcase, session_params[:password])
      if @user
        login!(@user)
        redirect_to user_path(@user)
      else
        @user = nil
        flash.now["errors"] = "Email or Password was incorrect"
        render :new
      end
    end

    def new
        render :new
    end
  
    def destroy
      current_user.reset_session_token!
      session[:session_token] = nil
      redirect_to root_url
    end
  end