class Post < ApplicationRecord
  WORDS_PER_MINUTE = 200
  MAX_SEARCH_TERMS = 5

  belongs_to :user
  has_many :comments, dependent: :delete_all

  normalizes :title, with: ->(title) { title.squish }

  validates :title, presence: true, length: { maximum: 150 }
  validates :body, presence: true, length: { maximum: 20_000 }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  # Every term must appear in the title or the body, so "rails testing"
  # matches a post titled "Rails" whose body mentions testing.
  def self.search(query)
    query.to_s.split.first(MAX_SEARCH_TERMS).reduce(all) do |posts, term|
      pattern = "%#{sanitize_sql_like(term)}%"
      posts.where(arel_table[:title].matches(pattern, "\\").or(arel_table[:body].matches(pattern, "\\")))
    end
  end

  def reading_time
    [ (body.to_s.split.size / WORDS_PER_MINUTE.to_f).ceil, 1 ].max
  end

  def authored_by?(someone)
    someone.present? && user_id == someone.id
  end
end
