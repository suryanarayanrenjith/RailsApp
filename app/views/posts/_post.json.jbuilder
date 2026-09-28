json.extract! post, :id, :title, :body, :comments_count, :created_at, :updated_at
json.author do
  json.extract! post.user, :id, :name
end
json.url post_url(post, format: :json)
