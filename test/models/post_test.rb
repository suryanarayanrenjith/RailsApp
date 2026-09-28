require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "is valid with a title, body, and author" do
    assert users(:alice).posts.build(title: "Title", body: "Body").valid?
  end

  test "requires a title and body" do
    post = Post.new
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
    assert_includes post.errors[:body], "can't be blank"
    assert_includes post.errors[:user], "must exist"
  end

  test "limits the length of the title and body" do
    post = users(:alice).posts.build(title: "x" * 151, body: "x" * 20_001)
    assert_not post.valid?
    assert post.errors.of_kind?(:title, :too_long)
    assert post.errors.of_kind?(:body, :too_long)
  end

  test "squishes whitespace in the title" do
    assert_equal "Hello world", Post.new(title: "  Hello \n  world ").title
  end

  test "newest_first orders by creation time, newest first" do
    assert_equal [ posts(:testing_tips), posts(:welcome) ], Post.newest_first.to_a
  end

  test "search matches the title or the body, ignoring case" do
    assert_equal [ posts(:welcome) ], Post.search("WELCOME").to_a
    assert_equal [ posts(:testing_tips) ], Post.search("last bug").to_a
  end

  test "search requires every term to match" do
    assert_equal [ posts(:welcome) ], Post.search("first paragraphs").to_a
    assert_empty Post.search("first bug")
  end

  test "search treats wildcard characters literally" do
    assert_empty Post.search("%")
    assert_empty Post.search("_")
  end

  test "a blank search returns every post" do
    assert_equal Post.count, Post.search("  ").count
    assert_equal Post.count, Post.search(nil).count
  end

  test "reading_time is at least one minute" do
    assert_equal 1, Post.new(body: "short").reading_time
    assert_equal 3, Post.new(body: "word " * 401).reading_time
  end

  test "authored_by? is true only for the author" do
    assert posts(:welcome).authored_by?(users(:alice))
    assert_not posts(:welcome).authored_by?(users(:bob))
    assert_not posts(:welcome).authored_by?(nil)
  end

  test "destroying a post removes its comments" do
    assert_difference -> { Comment.count }, -1 do
      posts(:welcome).destroy
    end
  end
end
