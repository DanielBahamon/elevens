class Line < ApplicationRecord
  enum status: {Pending: 0, Invoke: 1, Ejected: 2}
  belongs_to :user, foreign_key: 'user_id'
  belongs_to :club
  belongs_to :duel
 
  # validates_uniqueness_of :user_id, :message => "You can only join one group!"
  validates_uniqueness_of :user_id, :scope => [:duel_id], :message => "The user is already called up!"
  
  # validate :check_approval, on: :create

  # private

  # def check_approval
  #   if self.approve && self.duel.lines.where(approve: false).empty?
  #     errors.add(:base, "No puedes aceptar la convocatoria, ya todos los demás han aprobado.")
  #   end
  # end
end
 