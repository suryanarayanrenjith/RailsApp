require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Find buttons by their accessible names, e.g. "Dismiss message" for the flash's × button.
  Capybara.enable_aria_label = true

  private
    def sign_in_as(user, password: "password123")
      visit new_session_path
      fill_in "Email address", with: user.email_address
      fill_in "Password", with: password
      click_button "Sign in"

      assert_text "Welcome back, #{user.name}!"
    end
end
