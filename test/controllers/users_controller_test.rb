require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "show lists the user's posts without revealing their email address" do
    user = users(:alice)

    get user_url(user)

    assert_response :success
    assert_select "h1", user.name
    assert_select ".post-card-title", count: 1, text: posts(:welcome).title
    assert_no_match user.email_address, response.body
  end

  test "show has an empty state for users without posts" do
    user = User.create!(name: "Quiet Reader", email_address: "quiet@example.com", password: "password123")

    get user_url(user)
    assert_select ".empty-state", /Quiet Reader hasn’t published anything yet/
  end

  test "show offers signed-in users a shortcut to write on their own page" do
    sign_in_as users(:alice)

    get user_url(users(:alice))
    assert_select ".profile a", "Write a post"

    get user_url(users(:bob))
    assert_select ".profile a", count: 0
  end
end
