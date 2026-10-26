class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      start_new_session_for @user
      WelcomeMailer.with(user: @user).welcome.deliver_later
      redirect_to after_authentication_url, notice: "Your Wheelhouse account is ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # The role and the staff member are never taken from the form: a hand-sent
  # user[role]=owner is dropped, so the account is created with the default role.
  def registration_params
    params.expect(user: %i[email_address password password_confirmation])
  end
end
