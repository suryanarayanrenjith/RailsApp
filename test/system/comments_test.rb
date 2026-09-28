require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup { @post = posts(:welcome) }

  test "adding a comment updates the page without a reload" do
    sign_in_as users(:alice)
    visit post_url(@post)
    page.execute_script("window.withoutReload = true")

    fill_in "Add a comment", with: "Thanks for all the feedback!"
    click_on "Post comment"

    within "#comment_list" do
      assert_text "Thanks for all the feedback!"
      assert_selector ".comment", count: 2
    end
    assert_selector "#comments_count", text: "2 comments"
    assert_selector ".post-header .meta-comments", text: "2 comments"
    assert_field "Add a comment", with: ""
    assert page.evaluate_script("window.withoutReload"), "expected Turbo Streams to update the page in place"
  end

  test "deleting a comment" do
    sign_in_as users(:bob)
    visit post_url(@post)

    accept_confirm { click_on "Delete comment by Bob Reader" }

    assert_no_text "Great first post!"
    assert_text "No comments yet. Start the conversation!"
    assert_selector "#comments_count", text: "0 comments"
  end

  test "post authors can moderate comments but others cannot" do
    sign_in_as users(:alice)
    visit post_url(@post)
    assert_button "Delete comment by Bob Reader"

    visit post_url(posts(:testing_tips))
    assert_no_selector ".comment button"
  end
end
