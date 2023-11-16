class RequestsController < ApplicationController

    def check
        id = params["id"]
        request = Request.find_by(id: id)

        if request
            render json: request.to_json
        else
            render json: {errors: "Resource not found"}
        end
    end
end
