require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:welcome)
    @author = users(:alice)
    @other_user = users(:bob)
  end

  test "index lists posts newest first for anyone" do
    get posts_url
    assert_response :success
    assert_select ".post-card-title", count: 2
    assert_select ".post-card-title:first-of-type a", text: posts(:testing_tips).title
  end

  test "the root path shows the post index" do
    get root_url
    assert_response :success
    assert_select "h1", "Latest posts"
  end

  test "index filters posts by a search query" do
    get posts_url(query: "welcome")
    assert_response :success
    assert_select ".post-card-title", count: 1, text: @post.title
    assert_select ".search-summary", /1 result for “welcome”/
  end

  test "the page title includes the search query, escaped once" do
    get posts_url(query: "Tom & Jerry")
    assert_select "title", "Search: Tom & Jerry · RailsApp"
  end

  test "index explains when a search has no results" do
    get posts_url(query: "nothing matches this")
    assert_select ".empty-state h2", /No posts match/
  end

  test "index paginates posts" do
    11.times { |i| @author.posts.create!(title: "Extra #{i}", body: "Body") }

    get posts_url
    assert_select ".post-card", count: 10
    assert_select ".pagination-status", "Page 1 of 2"
    assert_select "a[rel=next][href=?]", posts_path(page: 2)

    get posts_url(page: 2)
    assert_select ".post-card", count: 3
    assert_select "a[rel=prev][href=?]", posts_path(page: 1)
  end

  test "pagination links keep the search query" do
    11.times { |i| @author.posts.create!(title: "Searchable #{i}", body: "Body") }

    get posts_url(query: "searchable")
    assert_select "a[rel=next][href=?]", posts_path(query: "searchable", page: 2)
  end

  test "index renders JSON with authors but no email addresses" do
    get posts_url(format: :json)
    assert_response :success

    json = response.parsed_body
    assert_equal 2, json.size
    assert_equal({ "id" => @author.id, "name" => @author.name }, json.find { |post| post["id"] == @post.id }["author"])
    assert_no_match "@example.com", response.body
  end

  test "new requires signing in" do
    get new_post_url
    assert_redirected_to new_session_url
  end

  test "new is available after signing in" do
    sign_in_as @author
    get new_post_url
    assert_response :success
    assert_select "input[type=submit][value=?]", "Create Post"
  end

  test "create makes the signed-in user the author" do
    sign_in_as @other_user

    assert_difference("Post.count") do
      post posts_url, params: { post: { title: "A new post", body: "Some text" } }
    end

    new_post = Post.order(:id).last
    assert_redirected_to post_url(new_post)
    assert_equal @other_user, new_post.user
  end

  test "create ignores attempts to assign another author" do
    sign_in_as @other_user
    post posts_url, params: { post: { title: "Sneaky", body: "Text", user_id: @author.id } }
    assert_equal @other_user, Post.find_by!(title: "Sneaky").user
  end

  test "create re-renders the form with errors when invalid" do
    sign_in_as @author

    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "", body: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "#post_title[aria-invalid=true][aria-describedby=post_title_error]"
    assert_select "#post_title_error", "Title can't be blank"
  end

  test "create requires signing in" do
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "Title", body: "Body" } }
    end
    assert_redirected_to new_session_url
  end

  test "JSON requests that need a session get 401 instead of a redirect" do
    post posts_url(format: :json), params: { post: { title: "Title", body: "Body" } }
    assert_response :unauthorized
  end

  test "show displays the post, its comments, and a sign-in prompt to visitors" do
    get post_url(@post)
    assert_response :success
    assert_select "h1", @post.title
    assert_select ".comment", count: 1
    assert_select ".comments-signin"
    assert_select "#new_comment", count: 0
    assert_select ".post-actions", count: 0
  end

  test "show escapes HTML in the post body" do
    @post.update!(body: "<script>alert('xss')</script>")
    get post_url(@post)
    assert_select ".post-body script", count: 0
    assert_includes response.body, "&lt;script&gt;"
  end

  test "show offers edit and delete controls only to the author" do
    sign_in_as @other_user
    get post_url(@post)
    assert_select ".post-actions", count: 0
    assert_select "#new_comment"

    sign_in_as @author
    get post_url(@post)
    assert_select ".post-actions a", "Edit post"
    assert_select ".post-actions button", "Delete post"
  end

  test "show responds with 404 for a missing post" do
    get post_url(id: 0)
    assert_response :not_found
  end

  test "show renders JSON" do
    get post_url(@post, format: :json)
    assert_response :success
    assert_equal @post.title, response.parsed_body["title"]
    assert_equal 1, response.parsed_body["comments_count"]
  end

  test "the author can edit and update a post" do
    sign_in_as @author

    get edit_post_url(@post)
    assert_response :success
    assert_select "input[type=submit][value=?]", "Update Post"

    patch post_url(@post), params: { post: { title: "Updated title" } }
    assert_redirected_to post_url(@post)
    assert_equal "Updated title", @post.reload.title
  end

  test "update re-renders the form with errors when invalid" do
    sign_in_as @author
    patch post_url(@post), params: { post: { body: "" } }
    assert_response :unprocessable_entity
    assert_select "#post_body_error", "Body can't be blank"
  end

  test "other users cannot edit, update, or destroy a post" do
    sign_in_as @other_user

    get edit_post_url(@post)
    assert_redirected_to post_url(@post)
    assert_equal "You can only change posts that you wrote.", flash[:alert]

    patch post_url(@post), params: { post: { title: "Hijacked" } }
    assert_redirected_to post_url(@post)
    assert_not_equal "Hijacked", @post.reload.title

    assert_no_difference("Post.count") { delete post_url(@post) }
    assert_redirected_to post_url(@post)
  end

  test "other users get 403 for JSON updates" do
    sign_in_as @other_user
    patch post_url(@post, format: :json), params: { post: { title: "Hijacked" } }
    assert_response :forbidden
  end

  test "the author can destroy a post" do
    sign_in_as @author

    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
    follow_redirect!
    assert_select ".flash-notice", /Post was successfully destroyed/
  end
end
