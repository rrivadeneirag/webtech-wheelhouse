class WelcomeMailer < ApplicationMailer
  # Sent after a successful sign-up, by a job (deliver_later).
  def welcome
    @user = params[:user]
    mail subject: "Welcome to Wheelhouse", to: @user.email_address
  end
end
