class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :require_ownership, only: %i[ edit update_details destroy ]
  before_action :require_logged_in, only: [:edit, :details]
  skip_before_action :require_logged_out, only: :show

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def details
    @user = current_user
    render :details
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
    r = Request.create!(resource_type: "bio", resource_id: current_user.id)
    
    if params["link"]
      payload = URI.open(params["link"])
    else
      payload = request.body
    end


    payload = helpers.pdf_to_text(payload)
    
    
    GenerateBioJob.perform_later(r, current_user, payload)
    render json: {ok: true, message: "Bio Started", id: r.id}
  end



  def create
    @user = User.new(user_params)
    @user.email = @user.email.downcase
    @user.password = params["user"]["password"]

    if @user.save
      login!(@user)
      redirect_to edit_user_path(@user), notice: "User was successfully created."
    else
      flash["errors"] = @user.errors.full_messages.join("\n")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    success_target = params["redirect"] == 'bio' ? user_url(@user) : details_url()
    failure_target = params["redirect"] == 'bio' ? :edit : :details
    if @user.update(user_params)
      flash["messages"] = "User was successfully updated."
      redirect_to success_target
    else
      flash.now[:errors] = @user.errors.full_messages
      render failure_target, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: "User was successfully destroyed."
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
