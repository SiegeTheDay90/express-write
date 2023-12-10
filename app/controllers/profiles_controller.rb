class ProfilesController < ApplicationController
  
  def new
    @propfile = Profile.new
  end
  
  def show
    @user = params["user_id"]
    @profile = Profile.find(params["id"])
  end

  def edit
    @profile = Profile.find(params["id"])
    redirect_to root_url and return unless current_user.id == @profile.user_id
  end

  def update
    @profile = Profile.find(params["id"])
    redirect_to root_url and return unless current_user.id == @profile.user_id
    if @profile.update(profile_params)
      flash["messages"] = "Profile was successfully updated."
      redirect_to profile_url(@profile)
    else
      flash.now[:errors] = @user.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
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

end