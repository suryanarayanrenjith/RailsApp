module UsersHelper
  AVATAR_COLORS = 6

  # A circle with the user's initials, colored consistently per user.
  def avatar_for(user, size: :small)
    tag.span user.initials, class: [ "avatar", "avatar-#{size}", "avatar-color-#{user.id % AVATAR_COLORS}" ], aria: { hidden: true }
  end
end
