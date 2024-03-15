class ProfilesController < ApplicationController

  
  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user_id = current_user.id
    
    if @profile.save
      flash.now["messages"] = ["Profile saved."]
      @user = @profile.user
      if params["set_active"] == "on"
        @profile.set_active()
      end
      render :show
    else
      flash.now["errors"] = @profile.errors.full_messages
      render :new
    end
  end
  
  def show
    @user = User.find(params["user_id"])
    @profile = Profile.find(params["id"])
    if @user.id != @profile.user_id
      flash["errors"] = ["Invalid Profile"]
      redirect_to root_url and return
    end
  end

  def edit
    @profile = Profile.find(params["id"])
    redirect_to root_url and return unless current_user.id == @profile.user_id
  end

  def update
    @profile = Profile.find(params["id"])
    redirect_to root_url and return unless current_user.id == @profile.user_id
    if @profile.update(profile_params)
      flash["messages"] = ["Profile was successfully updated."]
      if params["set_active"] == "on"
        @profile.set_active()
      end
      redirect_to user_profile_url(@profile.user_id, @profile)
    else
      flash.now[:errors] = @profile.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def set_active
    @profile = Profile.find(params["id"])
    @user = current_user
    redirect_to root_url unless @profile&.user_id == current_user.id
    @profile.set_active
    flash["messages"] = ["#{@profile.title} set to Active Profile."]
    redirect_to params["redirect"] == "listings" ? user_listings_url(current_user) : user_url(current_user)
  end
  
  def generate
    req = Request.create!(resource_type: "bio", resource_id: params["id"])

    # Is this a PDF or DOCX file?
    if ["PDF", "DOCX"].include?(params["resume_format"])
      # Are we given a link to the file?
      if !params["link"]&.empty?
        url = ""
        # Is it a Google Docs sharing link? Convert to direct download link.
        if params["link"].split("/").include?("docs.google.com") || params["link"].split("/").include?("drive.google.com")
            id = params["link"].split("/")[-2]
            url = "https://drive.google.com/uc?export=download&id=#{id}"
        else 
            url = params["link"]
        end

        # Try to open the link
        begin
          payload = URI.open(url)
        end

      else # The file is attached directly to the request
        payload = request.body
      end
    else # Just plain text
      payload = params["text"]
    end

    # Covert to text if it is a file
    case params["resume_format"]
    when "PDF"
      payload = helpers.pdf_to_text(payload)
    when "DOCX"
      payload = helpers.docx_to_text(payload)
    end

    

    GenerateBioJob.perform_later(req, current_user, payload)

    render json: {ok: true, message: "Bio Started", id: req.id}
  end

  def suggest_bullets
    description = params["description"]
    item = params["item"]

    OpenAI.configure do |config|
      config.access_token = ENV["OPENAI"]
    end
    client = OpenAI::Client.new

    
    response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo-16k",
            messages: [
                {role: "system", content:"Write 2-3 new-line separated sentences that could be used as job description bullet points for a resume. If possible, the points should include a metric that supports proficiency at that type of job. Format response as '...\\n...\\n..."},
                {role: "user", content: description ? "Existing description: #{description.split("\n").join(",")} Job: #{item}" : "Job: #{item}"}
            ],
            temperature: 1.4,
            max_tokens: 10000
        }
    )
    
    begin
      message = response["choices"][0]["message"]["content"]
      render plain: message
    rescue
      render plain: "NO"
    end
  end

  private

  def profile_params
    sp = params.require(:profile).permit(:title, :skills, :education, :experience, :industry, :aboutme, :projects)
    sp[:skills] = sp[:skills].split("\n") if sp[:skills]
    sp[:experience] = sp[:experience].split("\n") if sp[:experience]
    sp[:education] = sp[:education].split("\n") if sp[:education]
    sp[:projects] = sp[:projects].split("\n") if sp[:projects]

    return sp
  end

end