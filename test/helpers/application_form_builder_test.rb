require "test_helper"

class ApplicationFormBuilderTest < ActionView::TestCase
  setup do
    @post = Post.new
    @post.validate
  end

  test "links invalid fields to their error message" do
    render_form { |form| form.text_field(:title) + form.error_message(:title) }

    assert_select "input#post_title[aria-invalid=true][aria-describedby=post_title_error]"
    assert_select "p#post_title_error.field-error", "Title can't be blank"
  end

  test "keeps existing descriptions alongside the error" do
    render_form { |form| form.text_area(:body, aria: { describedby: "body_hint" }) }

    assert_select "textarea#post_body[aria-describedby=?]", "body_hint post_body_error"
  end

  test "leaves valid fields and forms without a model untouched" do
    @post = Post.new
    render_form { |form| form.text_field(:title) + form.error_message(:title) }
    assert_select "input#post_title:not([aria-invalid])"
    assert_select ".field-error", count: 0

    render html: form_with(url: "/search", builder: ApplicationFormBuilder) { |form| form.search_field(:query) }
    assert_select "input#query:not([aria-invalid])"
  end

  private
    def render_form(&block)
      render html: form_with(model: @post, url: "/posts", builder: ApplicationFormBuilder, &block)
    end
end
