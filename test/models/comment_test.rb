require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "requires a body no longer than 1,000 characters" do
    assert_not build_comment(body: "   ").valid?
    assert_not build_comment(body: "x" * 1_001).valid?
    assert build_comment(body: "x" * 1_000).valid?
  end

  test "strips surrounding whitespace from the body" do
    assert_equal "Nice post!", Comment.new(body: "\n  Nice post!  \n").body
  end

  test "keeps the post's comment counter up to date" do
    post = posts(:testing_tips)

    comment = assert_difference -> { post.reload.comments_count }, 1 do
      build_comment(post: post).tap(&:save!)
    end

    assert_difference -> { post.reload.comments_count }, -1 do
      comment.destroy
    end
  end

  test "can be deleted by its author or the post's author, and no one else" do
    comment = comments(:bobs_reply)

    assert comment.deletable_by?(users(:bob)), "comment author"
    assert comment.deletable_by?(users(:alice)), "post author"
    assert_not comment.deletable_by?(User.new(id: 0)), "someone else"
    assert_not comment.deletable_by?(nil), "signed-out visitor"
  end

  test "chronological orders oldest first" do
    newer = build_comment(post: posts(:welcome)).tap(&:save!)
    assert_equal [ comments(:bobs_reply), newer ], posts(:welcome).comments.chronological.to_a
  end

  private
    def build_comment(post: posts(:welcome), body: "Thanks for sharing!")
      Comment.new(post: post, user: users(:alice), body: body)
    end
end
