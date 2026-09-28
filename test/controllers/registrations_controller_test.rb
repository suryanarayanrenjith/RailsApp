require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "/signup is a friendly alias for the sign-up page" do
    get "/signup"
    assert_redirected_to "/registration/new"
  end

  test "new redirects signed-in users home" do
    sign_in_as users(:alice)
    get new_registration_path
    assert_redirected_to root_path
  end

  test "create signs up and signs in the new user" do
    assert_difference("User.count") do
      post registration_path, params: { user: {
        name: "Nina New", email_address: "Nina@Example.com", password: "password123", password_confirmation: "password123"
      } }
    end

    assert_redirected_to root_url
    assert cookies[:session_id]
    assert_equal "nina@example.com", User.order(:id).last.email_address
    follow_redirect!
    assert_select ".nav-profile", /Nina New/
  end

  test "create shows errors for invalid details" do
    assert_no_difference("User.count") do
      post registration_path, params: { user: {
        name: "", email_address: users(:alice).email_address, password: "short", password_confirmation: "different"
      } }
    end

    assert_response :unprocessable_entity
    assert_select "#user_name_error", "Name can't be blank"
    assert_select "#user_email_address_error", "Email address has already been taken"
    assert_select "#user_password_error", /too short/
    assert_select "#user_password_confirmation_error", /doesn't match/
    assert_nil cookies[:session_id]
  end
end
