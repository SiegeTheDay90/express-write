class UserMailer < ApplicationMailer

    def welcome_email
        @user = params[:user]
        @url = 'https://write-wise-4d2bfd5abb7a.herokuapp.com/'
        mail(to: @user.email, subject: 'Welcome to WriteWise!')
    end

    def reset_request
        @user = params[:user]
        @url = 'https://write-wise-4d2bfd5abb7a.herokuapp.com/confirmreset'
        @confirmation = Confirmation.new(user_id: @user.id)
        if @confirmation.save
            mail(to:@user.email, subject: 'Reset Password')
        end
    end

end
