require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:alice) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "/login is a friendly alias for the sign-in page" do
    get "/login"
    assert_redirected_to "/session/new"
  end

  test "new redirects signed-in users home" do
    sign_in_as @user
    get new_session_path
    assert_redirected_to root_path
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password123" }

    assert_redirected_to root_url
    assert cookies[:session_id]
    follow_redirect!
    assert_select ".flash-notice p", "Welcome back, #{@user.name}!"
  end

  test "create accepts the email address in any case" do
    post session_path, params: { email_address: @user.email_address.upcase, password: "password123" }
    assert_redirected_to root_url
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_select ".flash-alert", /Try another email address or password/
    assert_select "#email_address[value=?]", @user.email_address
  end

  test "create returns to the page that required signing in" do
    get new_post_url
    assert_redirected_to new_session_url

    post session_path, params: { email_address: @user.email_address, password: "password123" }
    assert_redirected_to new_post_url
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
    assert_not Session.exists?(Current.session&.id)
  end
end
