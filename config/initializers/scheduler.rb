require 'rufus-scheduler'

# Crear un scheduler (programador) para la tarea de eliminación de duelos
scheduler = Rufus::Scheduler.singleton

# Programar la tarea para que se ejecute cada minuto
scheduler.every '59m' do
  Duel.transaction do
    # Obtener el duelo sin rival y que le falta solo 1 minuto para empezar
    duel_to_delete = Duel.find_by(rival_id: nil, start_date: (Time.now - 1.hour)..(Time.now + 1.hour).end_of_minute)


    if duel_to_delete
      Reservation.where(duel_id: duel_to_delete.id).delete_all
      Line.where(duel_id: duel_to_delete.id).delete_all
      Invitation.where(duel_id: duel_to_delete.id).delete_all
      # Finalmente, eliminar el duelo sin rival
      duel_to_delete.destroy
    end
  end
end
