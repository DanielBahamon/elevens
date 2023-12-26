module ClubsHelper
  def user_is_owner?(user, club)
    user.present? && club.present? && user.id == club.user_id
  end
end
