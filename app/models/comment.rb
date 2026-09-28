class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user

  normalizes :body, with: ->(body) { body.strip }

  validates :body, presence: true, length: { maximum: 1_000 }

  scope :chronological, -> { order(:created_at, :id) }

  # Commenters can remove their own comments; post authors can moderate
  # the discussion under their posts.
  def deletable_by?(someone)
    someone.present? && (user_id == someone.id || post.authored_by?(someone))
  end
end
