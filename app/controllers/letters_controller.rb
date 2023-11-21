class LettersController < ApplicationController
    before_action :require_logged_in, except: :express
    skip_before_action :require_logged_out
    def new
        render :new
    end

    def show
        @letter = Letter.includes(:listing).find_by(id: params["id"])
        if !@letter || current_user.id != @letter.user_id
            redirect_to user_listings_url(current_user)
        else
            render :show
        end
    end
    def edit
        @letter = Letter.includes(:listing).find_by(id: params["id"])
        if !@letter || current_user.id != @letter.user_id
            redirect_to user_listings_url(current_user)
        else
            render :edit
        end
    end

    def express
        # Generate user bio
        pdf = nil
        if params["pdf"]
          pdf = params["pdf"].tempfile
        elsif params["link"]
          pdf = URI.open(params["link"])
        end
    
        bio = helpers.pdf_to_bio(pdf)
        
        # Generate listing object
        listing_obj = nil
        if params["type"] == "url"
            params["input"] = params["input"].split("?")[0]
            http_response = HTTP.headers("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36").get(params["input"])       
            if http_response.status >= 400
                flash.now['errors'] = "The link resulted in a 400+ error. Please check the url and ensure that viewing the listing does not require login."
                render 'application/show' and return
            elsif http_response.status >= 300
                flash.now['errors'] = "The link resulted in a redirect. Please use a direct link and ensure that viewing the listing does not require login."
                render 'application/show' and return
            else
                begin
                    listing_obj = helpers.http_to_listing(http_response)
                rescue
                    flash['errors'] = "There was an error while parsing the response. Please try again."
                end
            end
        else
            listing_obj = helpers.text_to_listing(params["input"])
        end

       
        # Generate letter
        letter = nil
        OpenAI.configure do |config|
            config.access_token = ENV["OPENAI"]
        end
        client = OpenAI::Client.new
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo-16k",
                messages: [
                    {role: "system", content:"Write cover 2-3 paragraph cover letter as job candidate."},
                    {role: "user", content: "Job: #{listing_obj}\nCandidate: #{bio}"}
                ],
                temperature: 1.1,
                max_tokens: 10000
            }
        )
        @message = response["choices"][0]["message"]["content"]
        @letter = Letter.new(body: @message)
        @listing = listing_obj
        render :express

    end

    def generate
        @listing = Listing.includes(:user).find_by(id: params["listing_id"])
        return redirect_to edit_user_url(current_user) unless @listing


        request = Request.create!(resource_type: "letter")
        GenerateLetterJob.perform_later(request, @listing, current_user)
        render json: {ok: true, message: "Letter Started", id: request.id}
    end

    def helpful
        @letter = Letter.find_by(id: params[:id])
        redirect_to users_url(current_user) and return unless @letter

        @letter.helpful = params["status"]
        if @letter.save
            render plain: "Success", status: 200
        else
            render plain: "Failure", status: 418
        end
    end

    def update
        #TODO What is this?
        render plain: (params.to_json)
    end
end