require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  setup do
    author = User.create!(name: "Prolific Writer", email_address: "prolific@example.com", password: "password123")
    @posts = Array.new(5) { |i| author.posts.create!(title: "Post #{i}", body: "Body", created_at: i.hours.ago) }
    @relation = author.posts.newest_first
  end

  test "returns the requested page of records" do
    pagination = Pagination.new(@relation, page: "2", per_page: 2)

    assert_equal 2, pagination.page
    assert_equal @posts[2, 2], pagination.records.to_a
    assert_equal 1, pagination.previous_page
    assert_equal 3, pagination.next_page
  end

  test "counts pages, rounding up" do
    pagination = Pagination.new(@relation, page: 1, per_page: 2)

    assert_equal 5, pagination.total_count
    assert_equal 3, pagination.total_pages
    assert pagination.multiple_pages?
  end

  test "the last page has no next page" do
    pagination = Pagination.new(@relation, page: 3, per_page: 2)

    assert_equal [ @posts.last ], pagination.records.to_a
    assert_nil pagination.next_page
  end

  test "clamps out-of-range and malformed page numbers" do
    assert_equal 3, Pagination.new(@relation, page: "99", per_page: 2).page
    assert_equal 1, Pagination.new(@relation, page: "-1", per_page: 2).page
    assert_equal 1, Pagination.new(@relation, page: "abc", per_page: 2).page
    assert_equal 1, Pagination.new(@relation, page: nil, per_page: 2).page
  end

  test "an empty relation still has one page" do
    pagination = Pagination.new(Post.none, page: 1)

    assert_equal 1, pagination.total_pages
    assert_nil pagination.previous_page
    assert_nil pagination.next_page
    assert_not pagination.multiple_pages?
  end
end
