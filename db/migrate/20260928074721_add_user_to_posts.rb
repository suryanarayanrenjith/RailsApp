class AddUserToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :user, null: false, foreign_key: true
    add_column :posts, :comments_count, :integer, null: false, default: 0

    change_column_null :posts, :title, false
    change_column_null :posts, :body, false

    add_index :posts, :created_at
  end
end
