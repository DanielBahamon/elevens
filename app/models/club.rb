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
  has_many :calendars, dependent: :destroy

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
    "https://d4s5cnqwbwfuf.cloudfront.net/assets/brands/v1/11_dark.svg"
  ].freeze
  


  COLORS = [
    '#FE676E', '#FD8F52', '#FD8F52', '#FFBD71', '#f55525',
    '#FFDCA2', '#FFEBD2', '#FFA364', '#FC7643', '#AF4F41',
    '#273248', '#E63946', '#F1FAEE', '#A8DACC', '#457B9D',
    '#1D3557', '#283D3B', '#197278', '#EDDDD4', '#0081A7',
    '#001B48', '#018ABE', '#D70040', '#DE3163', '#D2042D',
    '#E0115F', '#630330', '#FFC000', '#F4BB44', '#F4C430',
    '#93C572', '#FFAA33', '#2E8B57', '#009E60', '#008000',
    '#50C878', '#0047AB', '#000080', '#4169E1', '#008080',
    '#5D3FD3', '#00A36C'
  ].freeze
  

  
  has_one_attached :avatar
  # has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: DEFAULT_AVATARS.sample
  # validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  # def cover_photo(size)
  #   if self.club_photos.length > 0
  #     self.club_photos[0].image.url(size)
  #   else
  #     "blank.jpg"
  #   end
  # end
  def cover_photo(size)
    if self.club_photos.any? && self.club_photos.first.image.attached?
      self.club_photos.first.image
    else
      # 'blank.jpg' debe ser una imagen en tu directorio de assets o accesible vía URL directa
      'blank.jpg'
    end
  end
  
  attr_accessor :progress_percentage

  # enum sport_type: {Football: 0, Showbol: 1, Micro: 2, Benches: 3, Tenis: 4, Footvoley: 5}


  #RELATIONSHIPS



  def user_is_referee?(user)
    referees.exists?(user_id: user.id) # Verifica si el usuario es árbitro en este club
  end





end
  