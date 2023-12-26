class Rival < ApplicationRecord
  belongs_to :user
  belongs_to :club
  belongs_to :duel

  validates :duel_id, uniqueness: { scope: :rival_id }

  
  def invitation_status
    case self.status
    when 'pending'
      'pending'
    when 'accepted'
      'accepted'
    when 'rejected'
      'rejected'
    else
      'not_invited'
    end
  end

end
