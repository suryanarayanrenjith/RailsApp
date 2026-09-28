module PostsHelper
  # Posts and comments are plain text: escape everything, then turn blank
  # lines into paragraphs and single newlines into line breaks.
  def format_plain_text(text)
    simple_format(ERB::Util.html_escape(text))
  end

  def excerpt(post, length: 220)
    truncate(post.body.squish, length: length, separator: " ")
  end
end
