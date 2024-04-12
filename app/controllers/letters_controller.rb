class LettersController < ApplicationController
    
    def express
        req = Request.create!(resource_type: "temp_letter")
        # render json: {ok: false, errors: ["First error", "Second error"], id: req.id} and return
        # Listing to Text Payload
        if params["listing_type"] == "url"
            begin
                http_response = HTTP.headers("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36").get(params["input"])
            rescue => e
                errors = ["Error while trying to fetch Listing. Consider copy/pasting the listing as plain text."]
                req.update!(ok: false, complete: true, messages: errors )
                render json: {ok: false, errors: errors, id: req.id} and return
            end

            if http_response.status >= 400
                errors =[ "The link resulted in a 400+ error. Please check the url and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text."]
                req.update!(ok: false, complete: true, messages: errors )
                render json: {ok: false, errors: errors, id: req.id} and return
            elsif http_response.status >= 300
                errors = ["The link resulted in a redirect. Please use a direct link and ensure that viewing the listing does not require login. Consider copy/pasting the listing as plain text."]
                req.update!(ok: false, complete: true, messages: errors )
                render json: {ok: false, errors: errors, id: req.id} and return
            else
                @listing_payload = http_response.body.to_s
            end
        else
            @listing_payload = params["input"]
        end

        # Resume to Text Payload

        # Is this a PDF or DOCX file?
        if ["PDF", "DOCX"].include?(params["resume_format"])
        # Are we given a link to the file?
            if params["link"] && !params["link"]&.empty?
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
                    @bio_payload = URI.open(url)
                rescue => e
                    errors = [e.to_s]
                    req.update!(ok: false, complete: true, messages: errors )
                    render json: {ok: false, errors: errors, id: req.id} and return
                end
    
            else # The file is attached directly to the request
                @bio_payload = request.body
            end
        else # Just plain text
            @bio_payload = params["text"]
        end
    
        # Covert to text if it is a file
        begin
            case params["resume_format"]
            when "PDF"
                @bio_payload = helpers.pdf_to_text(@bio_payload)
            when "DOCX"
                @bio_payload = helpers.docx_to_text(@bio_payload)
            end
        rescue => e
            errors = ["File is corrupted or in the wrong format. If you think this is wrong, please report a bug.", e.to_s]
            req.update!(ok: false, complete: true, messages: errors )
            render json: {ok: false, errors: errors, id: req.id} and return
        end

        user_prompt = params["prompt"]
        # 
        ExpressJob.perform_later(req, @bio_payload, @listing_payload, params["listing_type"], user_prompt)
        render json: {ok: true, message: "Letter Started", id: req.id}
    end


    def temp
        @letter = TempLetter.find_by(secure_id: params["id"])
    end

    # def helpful
    #     @letter = Letter.find_by(id: params[:id])
    #     redirect_to users_url(current_user) and return unless @letter

    #     @letter.helpful = params["status"]
    #     if @letter.save
    #         render plain: "Success", status: 200
    #     else
    #         render plain: "Failure", status: 418
    #     end
    # end

    # def update
    #     @letter = Letter.find(params["id"])
    #     @letter.update(content: params["letter"]["content"])
    #     @letter.body = params["letter"]["content"].gsub("<br>", "\n").gsub("&nbsp;", "").gsub(/<[^>]*>/, "")
    #     flash.now["messages"] = ["Letter saved!"]
    #     render :show
    # end
end