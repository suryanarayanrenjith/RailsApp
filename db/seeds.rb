# Demo content for development. Safe to run repeatedly: bin/rails db:seed
#
# Demo accounts have well-known passwords, so they are never created in production.
if Rails.env.production?
  puts "Skipping demo seed data in production."
else
  ada = User.find_or_create_by!(email_address: "ada@example.com") do |user|
    user.name = "Ada Lovelace"
    user.password = "password123"
  end

  grace = User.find_or_create_by!(email_address: "grace@example.com") do |user|
    user.name = "Grace Hopper"
    user.password = "password123"
  end

  posts = [
    {
      author: ada,
      title: "Hello, RailsApp!",
      body: <<~BODY,
        Welcome to the new RailsApp. Anyone can read posts, and once you create an account you can write your own and join the discussion in the comments.

        Posts are plain text: leave a blank line between paragraphs and they will be formatted for you.

        Try searching for a word from this post, or open an author's name to see everything they have written.
      BODY
      comments: [
        { author: grace, body: "Congratulations on the launch! The new design looks great." },
        { author: ada, body: "Thank you, Grace! Let me know if you spot anything that could be better." }
      ]
    },
    {
      author: grace,
      title: "Five habits for writing readable code",
      body: <<~BODY
        Readable code is kind to the next person who opens the file, and that person is usually you.

        Name things after what they mean, not how they are implemented. Keep functions small enough to hold in your head. Delete dead code instead of commenting it out; version control remembers it for you.

        Write the test that would have caught the last bug you fixed. And when a comment explains what the code does, try rewriting the code so that it says so itself.
      BODY
    },
    {
      author: ada,
      title: "Why I keep a developer journal",
      body: <<~BODY,
        Every evening I write down three things: what I learned, what confused me, and what I want to try tomorrow.

        It takes five minutes, and after a few months it becomes the most useful documentation I own. Patterns emerge: the same kinds of bugs, the same gaps in understanding, the tools I keep reaching for.

        If you start one, keep it simple. A plain text file is plenty.
      BODY
      comments: [
        { author: grace, body: "I started doing this last year. Reading old entries is humbling in the best way." }
      ]
    }
  ]

  posts.each do |attributes|
    post = attributes[:author].posts.find_or_create_by!(title: attributes[:title]) do |new_post|
      new_post.body = attributes[:body]
    end

    Array(attributes[:comments]).each do |comment|
      post.comments.find_or_create_by!(user: comment[:author], body: comment[:body])
    end
  end

  puts "Seeded #{User.count} users, #{Post.count} posts and #{Comment.count} comments."
  puts "Sign in as ada@example.com or grace@example.com with password: password123"
end
