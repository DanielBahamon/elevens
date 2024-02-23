class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :duel
  belongs_to :referee

  validate :duration_must_be_greater_than_29_minutes
  validate :duration_must_be_less_than_six_hours
  # validate :unique_referee_per_duel
  validate :limit_approved_per_duel_and_position

  def duration
    (end_date - start_date) / 3600.0 # dividimos por 3600 para obtener las horas
  end

  enum position: { Principal: 0, "First": 1, "Second": 2, alternate: 3 }

  private



  def duration_must_be_less_than_six_hours
    if duration > 6
      errors.add(:end_date, "There cannot be more than 6 hours from the start date.")
    end
  end

  def unique_referee_per_duel
    existing_reservation = Reservation.where(duel_id: duel_id, referee_id: referee_id).where.not(id: id).exists?
    if existing_reservation
      errors.add(:base, "A reservation already exists for this duel with this referee.")
    end
  end

  def limit_approved_per_duel_and_position
    if approved
      if Reservation.where(duel_id: duel_id, position: position, approved: true).where.not(id: id).exists?
        errors.add(:base, "Only one approved registration per duel and position is allowed.")
      elsif Reservation.where(duel_id: duel_id, approved: true).where.not(position: position).count >= 2
        errors.add(:base, "Only two approved registrations per duel with different positions are allowed.")
      end
    end
  end
  
  def duration_must_be_greater_than_29_minutes
    start_time = self.start_date
    end_time = self.end_date
    duration_in_minutes = ((end_time - start_time) / 1.minute).to_i
    if duration_in_minutes < 30
      errors.add(:end_date, "It must be at least 30 minutes after the start time.")
    end
  end

end
