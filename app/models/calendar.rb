class Calendar < ApplicationRecord
  validates :day, presence: true
  validates :start_time, presence: true
  belongs_to :club
  belongs_to :user
  enum status: {pending: 0, accepted: 1, rejected: 2, canceled: 3}
end
