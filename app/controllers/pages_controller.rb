class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:home, :search, :radar, :live, :explore, :notifications]
  before_action :set_clubes, except: [:home, :search, :radar, :live, :explore, :notifications]
  helper_method :calculate_progress
  # include ApplicationHelper
 
  def home
    @clubs = Club.all
    @duels = Duel.where('duels.active = true AND duels.rival_id IS NOT ?', nil)
    # @rivals = club.joins(:rivals).where("'id' = #{@rivals.map {|key, value| [ key.rival_id]} }")
  end

  def battle
    @clubs = current_user.clubs
    @duels = current_user.duels
  end

  def calculate_progress(club)
    total_progress = 0
    total_tasks = 100
    total_progress += 20 if club.avatar.attached?
    total_progress += 20 if club.services_ready?
    total_progress += 20 if club.latitude?
    total_progress += 10 if ClubPhoto.exists?(club_id: club.id)
    total_progress += 10 if club.status == 'Published'
    # total_progress += 10 if Duel.exists?(club_id: club.id)

    created_clubs = Club.where(user_id: current_user.id)
    member_clubs = Club.joins(:memberships).where(memberships: { user_id: current_user.id }).distinct
    @clubs = (created_clubs + member_clubs).uniq
  
    active_club_ids = @clubs.map(&:id)
    # active_club_ids = current_user.clubs.where(id: @clubs.ids).pluck(:id)
    clubs_with_members_count = Club.joins(:memberships)
                                    .where(id: active_club_ids, memberships: { status: 1 })
                                    .group(:id)
                                    .count

    total_progress += clubs_with_members_count.keys.count * 20 if clubs_with_members_count[club.id].to_i >= 2

    normalized_progress = [total_progress, total_tasks].min
  end


  def console
    load_user_data
    load_duels_and_events
    calculate_event_times
    load_tasks_user

    
    created_clubs = Club.where(user_id: current_user.id)
    member_clubs = Club.joins(:memberships).where(memberships: { user_id: current_user.id }).distinct
    @clubs = (created_clubs + member_clubs).uniq
  
    @active_club_ids = @clubs.map(&:id) # Ahora es una variable de instancia
    user_club_ids = @clubs.pluck(:id)

    params[:start_date] ||= Date.today.to_s
    params[:end_date] ||= Date.today.to_s
    params[:task_id] ||= @tasks[0] ? @tasks[0].id : nil
  
    unless @tasks.blank?
      params[:task_id] ||= @tasks.first.id
      @task = Task.find_by(id: params[:task_id])
    end

    # @task = Task.find(params[:task_id])
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    first_of_month = (start_date - 1.months).beginning_of_month
    end_of_month = (start_date + 1.months).beginning_of_month

    # Obtener los duelos relacionados con los clubes del usuario
    @duels = Duel.where('(club_id IN (?) OR rival_id IN (?)) ', user_club_ids, user_club_ids)
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
    @tasks = Task.joins(:club).where(club_id: @active_club_ids)

    # Renderizar estos datos en la vista según sea necesario
    # @tasks = @tasks.joins(:club).joins(:duel)
    #               .select('tasks.*, clubs.*, duels.*' )
    #               .where('tasks.start_date BETWEEN ? AND ?', first_of_month, end_of_month)

    @tasks_with_clubs = @tasks.map do |task|
      duel = Duel.find_by(id: task.duel_id) # Usa find_by para evitar excepciones si no existe
      club = Club.find_by(id: task.club_id) # Igualmente, usa find_by para seguridad
      rival = duel ? Club.find_by(id: duel.rival_id) : nil
      task.as_json.merge(
        avatar: club&.avatar&.attached? ? url_for(club.avatar) : "URL de tu imagen por defecto",
        rival_avatar: rival&.avatar&.attached? ? url_for(rival.avatar) : "URL de tu imagen por defecto"

      )
    end

  end

  def search
  end

  def radar
    @clubs = Club.all
    @duels = Duel.where('duels.active = true AND duels.rival_id IS NOT ?', nil)
    # @rivals = Club.joins(:rivals).where("'id' = #{@rivals.map {|key, value| [ key.rival_id]} }")
  end

  def live
  end

  def explore
  end

  def players
    @players = User.all
  end

  def notifications
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  
  def preload_tasks
    today = Date.today
    @tasks = Task.where(user_id: current_user.id).order(deadline: :asc)
    tasks = @tasks.where('start_date >= :today OR end_date >= :today', today: Time.zone.now)

    render json: tasks
  end



  private

  def load_tasks_user
    @clubs.each do |club|
      if calculate_progress(club) < 100
        current_user.tasks.create(description: "Conclude #{club.club_name}", club_id: club.id, url: direction_club_path(club))
      end
    end
    if current_user.clubs.present?
      if Duel.where("(user_id = ? OR club_id IN (?)) AND active = ? AND start_date < ?", current_user.id, @active_club_ids, true, 1.week.ago).empty?
        current_user.tasks.create(description: "Estas perdiendo condición", url: battle_path)
      end
      if Duel.where("user_id = ? OR club_id IN (?)", current_user.id, @active_club_ids).empty?
        current_user.tasks.create(description: "You should try yourself on the field.", url: battle_path)
      end
    end
      
    created_clubs = Club.where(user_id: current_user.id).pluck(:id)
    member_clubs = Membership.where(user_id: current_user.id, status: 1).pluck(:club_id)
    club_ids = created_clubs + member_clubs
      
    # @tasks = Task.all.where(user_id: current_user.id).order(deadline: :asc)
    @tasks = Task.where(club_id: club_ids).order(deadline: :asc)
  end

  def load_user_data
    @clubs = current_user.clubs.includes(:memberships)
    @duels = current_user.duels
    @notifications = current_user.notifications.order(created_at: :desc).limit(9)
    
    @notificated = User.where(id: @notifications.pluck(:recipient_id))
    @sender = User.where(id: @notifications.pluck(:sender_id))

    @lines = Line.where(user_id: current_user.id, approve: 1)
    @memberships_of_user = Membership.where(status: 1, user_id: current_user.id)
    @memberships_of_clubs = Membership.where(status: 1, club_id: @clubs.ids)
    @membership_clubs = Club.joins(:memberships).where(memberships: { id: @memberships_of_user.pluck(:id) })
  end

  def load_duels_and_events
    @comings = Duel.where("((club_id IN (?) OR rival_id IN (?)) OR user_id = ?) AND active = ? AND start_date > ?", @clubs.ids, @clubs.ids, current_user.id, true, DateTime.now).order(start_date: :asc).limit(4)
    @pasts = Duel.where("((club_id IN (?) OR rival_id IN (?)) OR user_id = ?) AND active = ? AND start_date < ?", @clubs.ids, @clubs.ids, current_user.id, true, DateTime.now).order(start_date: :desc)
    @soon = Duel.where("club_id = ? AND active = ? AND start_date > ? AND rival_id IS NOT NULL", @clubs.ids.inspect, true, DateTime.now).order(:start_date).first
    @prev = Duel.where(club_id: @clubs.ids, rival_id: nil).order(start_date: :asc).first

    @allduels = [@soon, *@comings, *@pasts].compact
  end

  def calculate_event_times
    @event_time2 = calculate_remaining_time(@prev.start_date) if @prev
    @event_time1 = calculate_remaining_time(@soon.start_date) if @soon
  end

  def calculate_remaining_time(start_date)
    time_remaining = start_date - DateTime.now
    return start_date.strftime("%H:%M %p - %B %d, %Y") if time_remaining <= 0
    
    if time_remaining <= 1.month
      return time_remaining.inspect.gsub(/([0-9]+)\s?(\w)/) { |match| Regexp.last_match(1).to_i > 1 ? "#{Regexp.last_match(1)} #{Regexp.last_match(2)}" : "#{Regexp.last_match(1)} #{Regexp.last_match(2).singularize}" }
    else
      return start_date.strftime("%b %d, %Y %H:%M %p")
    end
  end

  def set_clubes
    @myclubs = current_user.clubs
    @mymemberships = current_user.memberships
    @mylines = Line.where(user_id: current_user.id, approve: 1)
    @myline_ids = @mylines.pluck(:club_id)
    @myclub_ids = @mymemberships.pluck(:club_id)
    @playclubs = Club.where(id: @myline_ids)
  end


end
