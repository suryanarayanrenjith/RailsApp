# Splits a relation into fixed-size pages. Out-of-range page numbers are
# clamped, so stale or hand-edited links still land on a real page.
class Pagination
  attr_reader :per_page

  def initialize(relation, page:, per_page: 10)
    @relation = relation
    @requested_page = page.to_i
    @per_page = per_page
  end

  def records
    @records ||= @relation.limit(per_page).offset((page - 1) * per_page)
  end

  def page
    @page ||= @requested_page.clamp(1, total_pages)
  end

  def total_count
    @total_count ||= @relation.count
  end

  def total_pages
    [ (total_count / per_page.to_f).ceil, 1 ].max
  end

  def previous_page
    page - 1 if page > 1
  end

  def next_page
    page + 1 if page < total_pages
  end

  def multiple_pages?
    total_pages > 1
  end
end
