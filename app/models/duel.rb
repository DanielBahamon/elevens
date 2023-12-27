class Duel < ApplicationRecord
  before_validation :set_uuid, on: :create

  belongs_to :user
  belongs_to :club
  has_many :rivals
  has_many :duel_photos
  # has_many :referees
  has_many :reservations
  has_many :goals
  has_many :lines, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :duels_referees
  has_many :referees, through: :duels_referees
  has_many :tasks, dependent: :destroy

  geocoded_by :address
  after_validation :geocode, if: :address_changed? 

  ransack_alias :user, :user_first_name_or_user_last_name_or_user_slug


  def set_uuid
    self.id = SecureRandom.uuid
  end

  def cover_photo(size)
    if self.duel_photos.length > 0
      self.duel_photos[0].image.url(size)
    else
      "blank.jpg"
    end
  end
  
  # enum height: {Snowy: 0, Moor: 1, Cold: 2, Temperate: 3, Warm: 4}
  enum status: {Pending: 0, Open: 1, Approved: 2, Cancelled: 3, Done: 4, Expired: 5}
  enum duel_type: {Friendly: 0, Bet: 1, Tournament: 2, Mundial: 3, League: 4}
  enum sport: {Futbol11: 11, Futbol10: 10, Futbol9: 9, Futbol8: 8, Futbol7: 7, Futbol6: 6, Futbol5: 5, Microfutbol: 4, Bancas: 3, Kings: 2, Legends: 1, Futvoley: 0, Futenis: 12, Futsal: 13}
  enum time_type: {Instant: 0, Schedule: 1, Training: 2}

  def height_name
    case height.to_sym
    when :Snowy
      "Nevado"
    when :Moor
      "Paramo"
    when :Cold
      "Frío"
    when :Temperate
      "Templado"
    when :Warm
      "Cálido"
    end
  end

  def time_remaining
    time_remaining = (self.start_date - DateTime.now).to_i.abs

    if time_remaining >= 1.year
      years = (time_remaining / 1.year).to_i
      years > 1 ? "#{years}y" : "#{years}y"
    elsif time_remaining >= 1.month
      months = (time_remaining / 1.month).to_i
      months > 1 ? "#{months}m" : "#{months}m"
    elsif time_remaining >= 1.week
      weeks = (time_remaining / 1.week).to_i
      weeks > 1 ? "#{weeks}w" : "#{weeks}w"
    elsif time_remaining >= 1.day
      days = (time_remaining / 1.day).to_i
      days > 1 ? "#{days}d" : "#{days}d"
    elsif time_remaining >= 1.hour
      hours = (time_remaining / 1.hour).to_i
      hours > 1 ? "#{hours}h" : "#{hours}h"
    elsif time_remaining >= 1.minute
      minutes = (time_remaining / 1.minute).to_i
      minutes > 1 ? "#{minutes}min" : "#{minutes}min"
    else
      seconds = time_remaining
      seconds > 1 ? "#{seconds}s" : "#{seconds}s"
    end
  end

  # Método para eliminar el duelo si no tiene rival y está próximo a la fecha de inicio
  def self.cleanup_duels_without_rival
    Duel.where(rival_id: nil).where('start_date <= ?', 5.minutes.from_now).destroy_all
  end

  
  def allow_edit_score?(user)
    # Lógica para verificar si el usuario tiene permiso para editar el puntaje de este duelo
    # Por ejemplo, si el usuario es árbitro o el propietario del duelo
    referees.exists?(user_id: user.id) || self.user_id == user.id
  end


end
  