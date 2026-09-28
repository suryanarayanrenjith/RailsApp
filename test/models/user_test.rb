require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "squishes whitespace in the name" do
    assert_equal "Ada Lovelace", User.new(name: "  Ada   Lovelace ").name
  end

  test "is valid with a name, email address, and password" do
    assert build_user.valid?
  end

  test "requires a name no longer than 50 characters" do
    assert_not build_user(name: "").valid?
    assert_not build_user(name: "x" * 51).valid?
  end

  test "requires a well-formed email address" do
    user = build_user(email_address: "not-an-email")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "requires a unique email address regardless of case" do
    user = build_user(email_address: users(:alice).email_address.upcase)
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "requires passwords to have at least 8 characters" do
    user = build_user(password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "can be updated without changing the password" do
    assert users(:alice).update(name: "Alice A. Author")
  end

  test "initials use the first letters of the first two names" do
    assert_equal "AA", users(:alice).initials
    assert_equal "C", User.new(name: "cher").initials
  end

  test "destroying a user removes their posts and comments" do
    assert_difference -> { Post.count } => -1, -> { Comment.count } => -1 do
      users(:bob).destroy
    end
  end

  private
    def build_user(**attributes)
      User.new(name: "New Person", email_address: "new@example.com", password: "password123", **attributes)
    end
end
