class Field < ApplicationRecord
  before_validation :set_uuid, on: :create

  belongs_to :users
  has_many :duels, dependent: :destroy
  
  geocoded_by :address
  after_validation :geocode, if: :address_changed? 

  
  extend FriendlyId
  friendly_id :name, use: :slugged
  

  def set_uuid
    self.id = SecureRandom.uuid
  end
end
