class Relationship < ApplicationRecord
	belongs_to :follower, class_name: "User"
	belongs_to :followed, class_name: "User"

	validates :follower_id, presence: true
	validates :followed_id, presence: true

	has_many :users, through: :clubs


  enum status: { fan: 0, friendship: 1, partner: 2 }
end
