class UsersController < ApplicationController
  before_action :set_user, only: %i[ edit update destroy ]
  before_action :require_ownership, only: %i[ edit update_details destroy ]
  before_action :require_logged_in, only: [:edit, :show]

  

  def new
    @user = User.new
  end

  def show
    @user = current_user
  end

  def update
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
    debugger
    @user = User.new(user_params)
    @user.email = @user.email.downcase
    @user.password = params["user"]["password"]
    title = params["industry"] || "My First Profile"
    industry = params["industry"] || ""
    
    if @user.save
      login!(@user)
      profile = Profile.create!(title: title, industry: industry, user_id: @user.id)
      profile.set_active()
      UserMailer.with(user: @user).welcome_email.deliver_now
      redirect_to user_path(@user), notice: "User was successfully created."
    else
      flash["errors"] = @user.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      flash.now["messages"] = ["User was successfully updated."]
      render :show
    else
      flash.now[:errors] = @user.errors.full_messages
      render :edit, status: :unprocessable_entity
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
      flash["messages"] = ["Invalid Token"]
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
        flash["messages"] = ["Password updated successfully. You may now log in."]
      else
        flash["errors"] = @user.errors.full_messages
      end
    else
      flash["errors"] = ["Invalid Token"]
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
        flash["messages"] = ["Reset initiated. Check your email inbox for instructions."]
        redirect_to root_url
      else
        flash.now[:errors] = ["Something went wrong."]
        render :reset
      end
    else
      flash.now[:errors] = ["User not found."]
      render :reset
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :credential, :first_name, :last_name, :session_token, :password)
    end

    def require_ownership
      current_user.id == @user.id
    end
end
