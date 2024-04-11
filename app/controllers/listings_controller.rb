class ListingsController < ApplicationController
    before_action :require_logged_in
    def new
        @listing = Listing.new
        render :new
    end

    def show
        @listing = Listing.find(params[:id])

        if @listing && @listing.user_id != current_user.id
            redirect_to root_url
        elsif @listing
            render :show
        else
            flash["errors"] = ["Listing not found."]
            redirect_to root_url
        end
    end

    def destroy
        @listing = Listing.find_by(id: params["id"])
        @listing.destroy
        flash["messages"] = ["Deleted listing #{params["id"]}"]
        redirect_to user_listings_url(current_user)
    end

    def update
        @listing = Listing.find_by(id: params["id"])
        if @listing.update(listing_params)
            flash["messages"] = ["Listing Updated Succesfully"]
            redirect_to listing_url(@listing)
        else
            flash["errors"] = @listing.errors.full_messages
            redirect_to user_listings_path(current_user)
        end
    end

    def edit
        @listing = Listing.find_by(id: params["id"])
        if @listing
            render :edit
        else
            flash["errors"] = ["Listing not found"]
            redirect_to user_listings_path(current_user)
        end
    end
    
    def generate
        
        @listing = Listing.new
        if params["listing_type"] == "url"
            # params["input"] = params["input"] Why was this here?
            http_response = HTTP.headers("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36").get(params["input"])

            
            if http_response.status >= 400
                flash.now['errors'] = "The link resulted in a 400+ error. Please check the url and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text."
                render :new and return
            elsif http_response.status >= 300
                flash.now['errors'] = "The link resulted in a redirect. Please use a direct link and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text."
                render :new and return
            else
                begin
                    request = Request.create!(resource_type: "listing")
                    
                    GenerateListingJob.perform_later(request, "http", http_response.body.to_s, current_user)
                    render json: {ok: true, message: "Listing Started", id: request.id}
                rescue
                    flash['errors'] = "There was an error while parsing the response. Please try again."
                end
            end
       
        else
            request = Request.create!(resource_type: "listing")
            GenerateListingJob.perform_later(request, "text", params["input"], current_user)
            render json: {ok: true, message: "Listing Started", id: request.id}
        end

        
    end

    def create
        @listing = Listing.new(**listing_params, user_id: current_user.id)
        if @listing.save
            render :edit
        else
            flash['errors'] = @listing.errors.full_messages.join("\n")
            render :new
        end
    end

    def index
        @listings = Listing.where(user_id: current_user.id)
        @user = current_user
        render :index
    end
end
