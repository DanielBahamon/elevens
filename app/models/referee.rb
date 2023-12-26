class Referee < ApplicationRecord
	belongs_to :user
	has_many :reservations


 	enum position: { Principal: 0, "Linea 1": 1, "Linea 2": 2, alternate: 3 }
end
