require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset" do
    user = users(:alice)
    email = PasswordsMailer.reset(user)

    assert_emails(1) { email.deliver_now }
    assert_equal [ user.email_address ], email.to
    assert_equal "Reset your password", email.subject
    assert_match "Hi #{user.name}", email.text_part.body.to_s
    assert_match %r{http://example.com/passwords/[^/]+/edit}, email.text_part.body.to_s
    assert_match "this password reset page", email.html_part.body.to_s
  end
end
