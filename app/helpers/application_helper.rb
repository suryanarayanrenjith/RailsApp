module ApplicationHelper
  def time_ago_tag(time)
    tag.time "#{time_ago_in_words(time)} ago", datetime: time.iso8601, title: l(time, format: :long)
  end
end
