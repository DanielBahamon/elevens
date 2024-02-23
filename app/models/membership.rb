class Membership < ApplicationRecord
  
  # attr_accessible :user_id, :club_id
  enum status: {Pending: 0, Approved: 1, Declined: 2}

  belongs_to :club
  belongs_to :user

  # validates_uniqueness_of :user_id, :message => "You can only join one group!"
  validates_uniqueness_of :user_id, :scope => [:club_id], :message => "You have already requested to join the team."

  validate :slug
  validate :firstname
  validate :lastname

  # has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :notifications

end
