require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:alice) }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "reset instructions sent"
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "reset instructions sent"
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_select ".flash-alert", /reset link is invalid/
  end

  test "update" do
    @user.sessions.create!

    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "new-password", password_confirmation: "new-password" }
      assert_redirected_to new_session_path
    end

    assert_empty @user.sessions, "resetting a password signs out every session"
    follow_redirect!
    assert_notice "Password has been reset"
  end

  test "update with non matching passwords" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "new-password", password_confirmation: "no-match" }
      assert_response :unprocessable_entity
    end

    assert_select ".form-errors", /Password confirmation doesn't match Password/
  end

  test "update with a password that is too short" do
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "short", password_confirmation: "short" }
      assert_response :unprocessable_entity
    end

    assert_select ".form-errors", /too short/
  end

  test "update with a blank password" do
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "", password_confirmation: "" }
      assert_response :unprocessable_entity
    end

    assert_select ".form-errors", /Password can't be blank/
  end

  private
    def assert_notice(text)
      assert_select ".flash-notice", /#{text}/
    end
end
