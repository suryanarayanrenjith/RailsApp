require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  test "visitors can browse and search posts" do
    visit root_url

    assert_selector "h1", text: "Latest posts"
    assert_selector ".post-card", count: 2

    fill_in "Search posts", with: "testing"
    click_button "Search"

    assert_text "1 result for “testing”"
    assert_selector ".post-card", count: 1
    click_on "Testing tips"

    assert_selector "h1", text: "Testing tips"
    assert_text "Sign in or create an account to join the discussion."
    assert_no_button "Delete post"
  end

  test "writing, editing, and deleting a post" do
    sign_in_as users(:alice)

    click_on "Write a post"
    fill_in "Title", with: "My second post"
    fill_in "Body", with: "First paragraph.\n\nSecond paragraph."
    click_on "Create Post"

    assert_text "Post was successfully created"
    assert_selector "h1", text: "My second post"
    assert_selector ".post-body p", count: 2

    click_on "Edit post"
    fill_in "Title", with: "My edited post"
    click_on "Update Post"

    assert_text "Post was successfully updated"
    assert_selector "h1", text: "My edited post"

    accept_confirm { click_on "Delete post" }

    assert_text "Post was successfully destroyed"
    assert_no_text "My edited post"
  end

  test "the post form shows validation errors" do
    sign_in_as users(:alice)
    visit new_post_url

    # Skip the browser's own required-field check to exercise server-side validation.
    page.execute_script("document.querySelector('form.form').noValidate = true")
    click_on "Create Post"

    assert_selector "#post_title_error", text: "Title can't be blank"
    assert_selector "#post_body_error", text: "Body can't be blank"
  end

  test "the title field counts remaining characters" do
    sign_in_as users(:alice)
    visit new_post_url

    assert_text "150 characters left"
    fill_in "Title", with: "Hello"
    assert_text "145 characters left"
  end

  test "writing a post requires signing in first" do
    visit new_post_url

    assert_text "Please sign in to continue."
    fill_in "Email address", with: users(:bob).email_address
    fill_in "Password", with: "password123"
    click_button "Sign in"

    assert_selector "h1", text: "Write a new post"
  end
end
