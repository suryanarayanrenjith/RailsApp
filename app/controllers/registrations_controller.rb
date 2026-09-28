class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  redirect_authenticated_users
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Too many sign-up attempts. Try again in a few minutes." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Welcome, #{@user.name}! Your account is ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
    end
end
