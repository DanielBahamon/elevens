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

  enum position: { Principal: 0, "Linea 1": 1, "Linea 2": 2, alternate: 3 }

  private



  def duration_must_be_less_than_six_hours
    if duration > 6
      errors.add(:end_date, "no puede haber más de 6 horas desde la fecha de inicio")
    end
  end

  def unique_referee_per_duel
    existing_reservation = Reservation.where(duel_id: duel_id, referee_id: referee_id).where.not(id: id).exists?
    if existing_reservation
      errors.add(:base, "Ya existe una reserva para este duelo con este árbitro")
    end
  end

  def limit_approved_per_duel_and_position
    if approved
      if Reservation.where(duel_id: duel_id, position: position, approved: true).where.not(id: id).exists?
        errors.add(:base, "Solo se permite un registro aprobado por duelo y posición")
      elsif Reservation.where(duel_id: duel_id, approved: true).where.not(position: position).count >= 2
        errors.add(:base, "Solo se permiten dos registros aprobados por duelo con diferentes posiciones")
      end
    end
  end
  
  def duration_must_be_greater_than_29_minutes
    start_time = self.start_date
    end_time = self.end_date
    duration_in_minutes = ((end_time - start_time) / 1.minute).to_i
    if duration_in_minutes < 30
      errors.add(:end_date, "debe ser al menos 30 minutos después de la hora de inicio")
    end
  end

end
