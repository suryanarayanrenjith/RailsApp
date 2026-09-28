require "test_helper"

class PostsHelperTest < ActionView::TestCase
  test "format_plain_text escapes HTML and turns blank lines into paragraphs" do
    html = format_plain_text("Hello <b>world</b>\n\nSecond <script>alert(1)</script>\nline")

    assert_equal "<p>Hello &lt;b&gt;world&lt;/b&gt;</p>\n\n<p>Second &lt;script&gt;alert(1)&lt;/script&gt;\n<br />line</p>", html
  end

  test "excerpt collapses whitespace and truncates on a word boundary" do
    post = Post.new(body: "One two\n\nthree four five")

    assert_equal "One two three four five", excerpt(post)
    assert_equal "One two...", excerpt(post, length: 12)
  end
end
