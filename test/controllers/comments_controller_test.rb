require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:welcome)
    @comment = comments(:bobs_reply)
  end

  test "commenting requires signing in" do
    assert_no_difference("Comment.count") do
      post post_comments_url(@post), params: { comment: { body: "Hello" } }
    end
    assert_redirected_to new_session_url
  end

  test "create appends the comment with a Turbo Stream" do
    sign_in_as users(:alice)

    assert_difference("Comment.count") do
      post post_comments_url(@post), params: { comment: { body: "Thanks for reading!" } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal Mime[:turbo_stream], response.media_type
    assert_select "turbo-stream[action=append][target=comment_list]" do
      assert_select "template", /Thanks for reading!/
    end
    assert_select "turbo-stream[action=update][targets=?]", "#comments_count, #post_#{@post.id} .meta-comments" do
      assert_select "template", "2 comments"
    end
    assert_select "turbo-stream[action=replace][target=new_comment]"
    assert_equal users(:alice), Comment.order(:id).last.user
  end

  test "create redirects back to the post without Turbo" do
    sign_in_as users(:alice)
    post post_comments_url(@post), params: { comment: { body: "Plain HTML works too" } }

    comment = Comment.order(:id).last
    assert_redirected_to post_url(@post, anchor: "comment_#{comment.id}")
  end

  test "create shows validation errors in the form" do
    sign_in_as users(:alice)

    assert_no_difference("Comment.count") do
      post post_comments_url(@post), params: { comment: { body: "" } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action=replace][target=new_comment]" do
      assert_select "template", /Body can't be blank/
    end
  end

  test "commenters can delete their own comments" do
    sign_in_as users(:bob)

    assert_difference("Comment.count", -1) do
      delete post_comment_url(@post, @comment), as: :turbo_stream
    end

    assert_select "turbo-stream[action=remove][target=comment_#{@comment.id}]"
    assert_select "turbo-stream[action=update]" do
      assert_select "template", "0 comments"
    end
  end

  test "post authors can delete comments on their posts" do
    sign_in_as users(:alice)

    assert_difference("Comment.count", -1) do
      delete post_comment_url(@post, @comment)
    end
    assert_redirected_to post_url(@post)
  end

  test "other users cannot delete comments" do
    intruder = User.create!(name: "Intruder", email_address: "intruder@example.com", password: "password123")
    sign_in_as intruder

    assert_no_difference("Comment.count") do
      delete post_comment_url(@post, @comment)
    end
    assert_redirected_to post_url(@post)
    assert_equal "You can only delete your own comments.", flash[:alert]
  end

  test "comments are looked up within their post" do
    sign_in_as users(:bob)
    delete post_comment_url(posts(:testing_tips), @comment)
    assert_response :not_found
  end
end
