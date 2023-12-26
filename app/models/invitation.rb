class Invitation < ApplicationRecord
  belongs_to :club
  belongs_to :duel
  
  validate :unique_email_for_duel
  validate :unique_cel_for_duel


  private

  def unique_email_for_duel
    if self.email.present? && self.duel_id.present?
      existing_invitation = Invitation.where(duel_id: self.duel_id, email: self.email).first
      if existing_invitation && existing_invitation != self
        errors.add(:email)
      end
    end
  end
  def unique_cel_for_duel
    if self.cel.present? && self.duel_id.present?
      existing_invitation = Invitation.where(duel_id: self.duel_id, cel: self.cel).first
      if existing_invitation && existing_invitation != self
        errors.add(:cel)
      end
    end
  end

end
 