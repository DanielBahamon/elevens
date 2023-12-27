class Club < ApplicationRecord
  before_validation :set_uuid, on: :create

  belongs_to :user
  has_many :users, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :duels
  has_many :rivals, through: :duels
  has_many :lines, through: :duels
  has_many :invitations, through: :duels
  has_many :club_photos
  has_many :goals
  has_many :referees
  has_many :relationships, dependent: :destroy, as: :followable
  has_many :followers, through: :relationships, source: :user
  has_many :tasks, dependent: :destroy

  geocoded_by :address
  after_validation :geocode, if: :address_changed? 

  validates :captain, presence: true
  validates :club_name, presence: true

  extend FriendlyId
  friendly_id :club_name, use: :slugged

  def set_uuid
    self.id = SecureRandom.uuid
  end


  DEFAULT_AVATARS = [
    "//d4s5cnqwbwfuf.cloudfront.net/assets/images/website/v1/eleven1.png",
    "//d4s5cnqwbwfuf.cloudfront.net/assets/images/website/v1/eleven2.png",
    "//d4s5cnqwbwfuf.cloudfront.net/assets/images/website/v1/eleven3.png",
    "//d4s5cnqwbwfuf.cloudfront.net/assets/images/website/v1/eleven4.png",
    "//d4s5cnqwbwfuf.cloudfront.net/assets/images/website/v1/eleven5.png"
  ].freeze

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: DEFAULT_AVATARS.sample
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  def cover_photo(size)
    if self.club_photos.length > 0
      self.club_photos[0].image.url(size)
    else
      "blank.jpg"
    end
  end
  
  attr_accessor :progress_percentage

  # enum sport_type: {Football: 0, Showbol: 1, Micro: 2, Benches: 3, Tenis: 4, Footvoley: 5}


  #RELATIONSHIPS



  def user_is_referee?(user)
    referees.exists?(user_id: user.id) # Verifica si el usuario es árbitro en este club
  end
end
  