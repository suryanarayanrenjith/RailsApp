class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  redirect_authenticated_users only: :new
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Too many sign-in attempts. Try again in a few minutes." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Welcome back, #{user.name}!"
    else
      flash.now[:alert] = "Try another email address or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other, notice: "You have been signed out."
  end
end
