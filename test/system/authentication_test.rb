require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "signing up, signing out, and signing back in" do
    visit root_url
    click_on "Sign up"

    fill_in "Display name", with: "Nina New"
    fill_in "Email address", with: "nina@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm password", with: "password123"
    click_on "Create account"

    assert_text "Welcome, Nina New! Your account is ready."
    assert_link "Write a post"

    click_button "Sign out"
    assert_text "You have been signed out."
    assert_link "Sign in"

    sign_in_as User.find_by!(email_address: "nina@example.com")
  end

  test "a wrong password keeps the email address filled in" do
    visit new_session_url
    fill_in "Email address", with: users(:alice).email_address
    fill_in "Password", with: "not-the-password"
    click_button "Sign in"

    assert_text "Try another email address or password."
    assert_field "Email address", with: users(:alice).email_address
  end

  test "flash messages can be dismissed" do
    sign_in_as users(:alice)

    click_on "Dismiss message"
    assert_no_text "Welcome back"
  end
end
