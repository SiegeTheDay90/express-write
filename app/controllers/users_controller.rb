class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :require_ownership, only: %i[ edit update_details destroy ]
  before_action :require_logged_in, only: [:edit, :details]
  skip_before_action :require_logged_out, only: [:show]

  

  def new
    @user = User.new
  end

  def details
    @user = current_user
  end

  def update_details
    if @user.update_details(params["updated_details"])
      render :details
    else
      flash.now["errors"] = @user.errors.full_messages
      render :details
    end
  end


  def edit
    @listings = @user.listings || []
    @letters = @user.letters || []
    render :edit
  end

  def generate
    req = Request.create!(resource_type: "bio", resource_id: current_user.id)
    
    if params["link"]
      payload = URI.open(params["link"])
    else
      payload = request.body
    end

    payload = helpers.pdf_to_text(payload)
    
    render json: {ok: true, message: "Bio Started", id: req.id}
  end



  def create
    @user = User.new(user_params)
    @user.email = @user.email.downcase
    @user.password = params["user"]["password"]

    if @user.save
      login!(@user)
      UserMailer.with(user: @user).welcome_email.deliver_now
      redirect_to edit_user_path(@user), notice: "User was successfully created."
    else
      flash["errors"] = @user.errors.full_messages.join("\n")
      render :new, status: :unprocessable_entity
    end
  end



  def destroy
    @user.destroy
    redirect_to users_url, notice: "User was successfully destroyed."
  end
  
  ### Password Reset

  def confirm
    @token = params[:token]

    if !@token
      redirect_to root_url and return
    end

    @user = User.find_by(reset_password_token: @token)

    if !@user
      flash["messages"] = "Invalid Token"
      redirect_to root_url and return
    end

    render :confirm    
  end
  
  def reset_password
    password = params[:password]
    @user = User.find_by(reset_password_token: params[:token])

    if @user
      @user.password = password
      @user.reset_password_token = nil
      @user.reset_password_sent_at = nil
      if @user.save
        flash["messages"] = "Password updated successfully. You may now log in."
      else
        flash["errors"] = @user.errors.full_messages.to_s
      end
    else
      flash["errors"] = "Invalid Token"
    end
    redirect_to root_url
  end

  def request_reset
    @user = User.find_by(email: params[:email])
    if @user
      @user.reset_password_token = SecureRandom.alphanumeric(10)
      @user.reset_password_sent_at = Date.today
      if @user.save
        UserMailer.with(user: @user).reset_request.deliver_now
        flash["messages"] = "Reset initiated. Check your email inbox for instructions."
        redirect_to root_url
      else
        flash.now[:errors] = "Something went wrong."
        render :reset
      end
    else
      flash.now[:errors] = "User not found."
      render :reset
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      up = params.require(:user).permit(:email, :credential, :first_name, :last_name, :skills, :education, :experience, :completion, :industry, :session_token, :aboutme, :projects)
      up[:skills] = up[:skills].split("\n") if up[:skills]
      up[:experience] = up[:experience].split("\n") if up[:experience]
      up[:education] = up[:education].split("\n") if up[:education]
      up[:projects] = up[:projects].split("\n") if up[:projects]

      return up
    end

    def require_ownership
      current_user.id == @user.id
    end
end
