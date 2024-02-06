class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def host
    
    @tasks = Task.all.where(user_id: current_user.id).order(deadline: :asc)
    # Obtén todos los clubes que el usuario ha creado
    created_clubs = Club.where(user_id: current_user.id)

    # Obtén todos los clubes de los que el usuario es miembro
    member_clubs = Club.joins(:memberships).where(memberships: { user_id: current_user.id })

    # Combina los clubes en un solo conjunto de clubes
    clubs = created_clubs + member_clubs

    user_club_ids = clubs.pluck(:id)

    params[:start_date] ||= Date.today.to_s
    params[:end_date] ||= Date.today.to_s
    params[:task_id] ||= @tasks[0] ? @tasks[0].id : nil
  
    if params[:task_id]
      @task = Task.find(params[:task_id])
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
  
      first_of_month = (start_date - 1.months).beginning_of_month
      end_of_month = (start_date + 1.months).beginning_of_month
  
      # Obtener los duelos relacionados con los clubes del usuario
      @duels = Duel.where('(club_id IN (?) OR rival_id IN (?)) AND start_date BETWEEN ? AND ?', user_club_ids, user_club_ids, first_of_month, end_of_month)
      @duels_with_clubs = []
  
      # Obtener datos específicos de los clubes local y visitante para cada duelo
      @duels.each do |duel|
        local_club = Club.find_by(id: duel.club_id)
        rival_club = Club.find_by(id: duel.rival_id)
  
        @duels_with_clubs << {
          duel: duel,
          local_club: local_club,
          rival_club: rival_club
        }
      end
  
      # Renderizar estos datos en la vista según sea necesario
      @tasks = @tasks.joins(:club).joins(:duel)
                    .select('tasks.*, clubs.*, duels.*' )
                    .where('tasks.start_date BETWEEN ? AND ?', first_of_month, end_of_month)

      @tasks_with_clubs = @tasks.map do |task|
        duel = Duel.find_by(id: task.duel_id) # Usa find_by para evitar excepciones si no existe
        club = Club.find_by(id: task.club_id) # Igualmente, usa find_by para seguridad
        rival = duel ? Club.find_by(id: duel.rival_id) : nil
        task.as_json.merge(
          avatar: club&.avatar&.url, # Usa el avatar del club o la imagen por defecto
          rival_avatar: rival&.avatar&.url  # Usa el avatar del rival o la imagen por defecto
        )
      end

    else
      @task = nil
      @tasks = []
    end
  end

  private

  def set_user
    @user = current_user
  end
end
