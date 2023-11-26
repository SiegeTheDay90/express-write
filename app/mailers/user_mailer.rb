class UserMailer < ApplicationMailer

    def welcome_email
        @user = params[:user]
        @token = params[:token]
        mail(to: @user.email, subject: 'Welcome to WriteWise!')
    end

    def reset_request
        @user = params[:user]
        mail(to:@user.email, subject: 'Reset Password')
    end

end
