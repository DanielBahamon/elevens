class Referee < ApplicationRecord
	belongs_to :user
	has_many :reservations


 	enum position: { Principal: 0, "First": 1, "Second": 2, alternate: 3 }
end
