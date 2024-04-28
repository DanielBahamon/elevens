class DuelsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_club
  before_action :set_breadcrumbs, except: [:index, :new, :create, :panel]
  before_action :set_duel, except: [:index, :new, :create]
  before_action :set_referee, except: [:index, :new, :create]
  before_action :set_local_and_guess, except: [:index, :new, :create]
  before_action :set_formations
  before_action :is_authorised, only: [:new, :create, :referee,  :budget, :description, :visuals, :location]
  before_action :authorize_creator, only: [ :budget, :description, :visuals, :location, :location, :destroy]
  before_action :set_time_zone, only: [:create]
  helper_method :duel_progress

  def index
    @duels = current_user.duels
  end

  def new
    @duel = @club.duels.new
    # @selected_date = params[:selected_date]
    if params[:selected_date]
      @selected_date = Time.zone.parse(params[:selected_date])
    else
      @selected_date = nil
    end
    
    # @active_club_ids = @clubs.map(&:id) 
    @tasks = Task.joins(:club).where(club_id: @club.id)
    @tasks_with_clubs = @tasks.map do |task|
      duel = Duel.find_by(id: task.duel_id)
      club = Club.find_by(id: task.club_id) 
      rival = duel ? Club.find_by(id: duel.rival_id) : nil
      task.as_json.merge(
        avatar: club&.avatar&.attached? ? url_for(club.avatar) : "URL de tu imagen por defecto",
        rival_avatar: rival&.avatar&.attached? ? url_for(rival.avatar) : "URL de tu imagen por defecto"

      )
    end
  end

  def create
    @duel = @club.duels.build(duel_params)
    @duel.members = calculate_members(@duel.sport)

    start_date = Time.zone.parse(duel_params[:start_date]).utc
    end_date = Time.zone.parse(duel_params[:end_date]).utc
    hours = (end_date - start_date).to_i

    if @duel.save
      Task.create(
        description: "Sports Duel",
        start_date: start_date,
        end_date: end_date,
        user: current_user,
        club_id: @club.id,
        duel_id: @duel.id
      )
      redirect_to panel_club_duel_path(@club, @duel), notice: "Done!"
    else
      render :new, notice: "Oops! Something went wrong."
    end
  end

  def control
    referee_access
  end

  def calculate_members(sport)
    case sport
    when "Futbol11"
      return 11
    when "Futbol10"
      return 10
    when "Futbol9"
      return 9
    when "Futbol8"
      return 8
    when "Futbol7"
      return 7
    when "Futbol6"
      return 6
    when "Microfutbol", "Futsal"
      return 5
    when "Bancas"
      return 4
    when "Futvoley", "Futenis", "Kings"
      return 2
    when "Legends"
      return 1
    else
      return nil
    end
  end

  def calculate_approved_members_count(club)
    club.memberships.approved.count
  end

  def update
    if @duel.update(duel_params)
      flash[:notice] = "Done!"
    else
      flash[:notice] = "Oops! Something went wrong"
    end
    redirect_back(fallback_location: request.referer)
  end
  
  def minimum_members_confirmed?
    required_members = {
      Futbol11: 11,
      Futbol10: 10,
      Futbol9: 9,
      Futbol8: 8,
      Futbol7: 7,
      Futbol6: 6,
      Futbol5: 5,
      Microfutbol: 4,
      Bancas: 3,
      Kings: 2,
      Legends: 1, 
      Futvoley: 2, 
      Futenis: 2,  
      Futsal: 5
    }

    lines.where(approve: true).count >= required_members[sport.to_sym]
  end

  def panel
    add_breadcrumb 'Dashboard', nil
    
    @referees = Referee.all
    @reservation = Reservation.new
    @invitation = Invitation.new

    @available_clubs = Club.where(id: available_club_ids).paginate(page: params[:page], per_page: 1)

    @no_approve_clubs = Club.where(id: @duel.rivals.where(approve: false).pluck(:rival_id))
    @approve_clubs = Club.where(id: @duel.rivals.where(approve: true).pluck(:rival_id))

    @local_lines = Line.where(club_id: @local.id, status: 1, duel_id: @duel.id)
    @no_local_lines = Line.where(club_id: @local.id, duel_id: @duel.id)
    @local_lines_approve = Line.where(club_id: @local.id, status: 1, approve: true, duel_id: @duel.id)

    @local_members = @local.memberships
    @locals = User.where(id: @local_members.pluck(:user_id)).where(id: @local_lines.pluck(:user_id))
    @local_users = User.where(id: @local_members.pluck(:user_id))
    @local_users_approved = User.where(id: @local_lines_approve.pluck(:user_id)).where(id: @local_members.pluck(:user_id))
    @local_users_convoked = User.where(id: Line.where(duel_id: @duel.id).pluck(:user_id))

    @local_us = @local_users 

    if @guess.present?
      @guess_lines = Line.where(club_id: @guess.id, status: 1, duel_id: @duel.id)
      @no_guess_lines = Line.where(club_id: @guess.id, duel_id: @duel.id)

      @guess_members = @guess.memberships
      @guesses = User.where(id: @guess_members.pluck(:user_id)).where(id: @guess_lines.pluck(:user_id))
      @guess_users = User.where(id: @guess_members.pluck(:user_id))
      @guess_users_approved = User.where(id: @guess_lines.where(approve: true).pluck(:user_id))
    end

    @position_choices = User.distinct.pluck(:position)
    @selected_positions = params[:selected_positions] || {}

    if @local_users_approved.present?
      # desired_positions = @local_users_approved.pluck(:position).map { |positions| positions.split(',').map(&:strip) }.flatten.uniq
      desired_positions = @local_users_approved.pluck(:position).map { |positions| positions.to_s.split(',').map(&:strip) }.flatten.compact.uniq
      @local_available_position = @local_users.select do |user|
        positions = if user.position.present?
              user.position.split(',').map(&:strip)
            else
              []  # O cualquier valor predeterminado que desees en caso de que position sea nulo
            end
        (positions & desired_positions).any? 
      end
    end

    if @duel.formation.present?
      @formacion_actual = @duel.formation
    end
    
    @duel.progress_percentage = calculate_duel_progress(@duel)
  end

  def members
    add_breadcrumb 'Members', nil
    @local = @duel.club
    @guess = Club.find_by(id: @duel.rival_id) if @duel.rival_id.present?

    unless current_user.id == @local.user_id || (@guess&.user_id == current_user.id)
      redirect_back(fallback_location: root_path, alert: "You do not have sufficient authorization for this.")
      return
    end

    @no_approve_clubs = Club.where(id: @duel.rivals.where(approve: false).pluck(:rival_id))
    @approve_clubs = Club.where(id: @duel.rivals.where(approve: true).pluck(:rival_id))

    @local_lines = Line.where(club_id: @local.id, status: 1, duel_id: @duel.id)
    @no_local_lines = Line.where(club_id: @local.id, duel_id: @duel.id)
    @local_lines_approve = Line.where(club_id: @local.id, status: 1, approve: true, duel_id: @duel.id)

    @local_members = @local.memberships
    @locals = User.where(id: @local_members.pluck(:user_id)).where(id: @local_lines.pluck(:user_id))
    @local_users = User.where(id: @local_members.pluck(:user_id))
    @local_users_approved = User.where(id: @local_lines_approve.pluck(:user_id)).where(id: @local_members.pluck(:user_id))
    @local_users_convoked = User.where(id: Line.where(duel_id: @duel.id).pluck(:user_id))

    local_member_ids = @local_members.ids

    @local_us = @local_users 


    if @guess.present?
      @guess_lines = Line.where(club_id: @guess.id, status: 1, duel_id: @duel.id)
      @no_guess_lines = Line.where(club_id: @guess.id, duel_id: @duel.id)

      @guess_members = @guess.memberships
      @guesses = User.where(id: @guess_members.pluck(:user_id)).where(id: @guess_lines.pluck(:user_id))
      @guess_users = User.where(id: @guess_members.pluck(:user_id))
      @guess_users_approved = User.where(id: @guess_lines.where(approve: true).pluck(:user_id))
    end

    @position_choices = User.distinct.pluck(:position)
    @selected_positions = params[:selected_positions] || {}
  end

  def calculate_duel_progress(duel)
    total_progress = 0
    total_tasks = 100
    
    total_progress += 25 if duel.minimum_members_confirmed?
    total_progress += 25 if duel.price?
    total_progress += 25 if duel.latitude? 
    total_progress += 25 if duel.color_local?
    
    [total_progress, total_tasks].min
  end

  def show
    # @duels = current_user.duels
    @duels = Duel.all
    @all = @duel.rivals
    @no_approve = @all.where(approve: false)
    @approve = @all.where(approve: true)
    @no_approve_clubs = Club.where(id: @no_approve.map(&:rival_id))
    @approve_clubs = Club.all.where(id: @approve.map(&:rival_id))

    #clubS
    @local = Club.where("clubs.id = '#{@duel.club_id}'")[0] 
    if @duel.rival_id.present?
      @guess = Club.where("clubs.id = '#{@duel.rival_id}'")[0]
    end

    #LINES
    @local_lines = Line.where("lines.club_id == '#{@local.id}' AND lines.status == 1 AND lines.duel_id == '#{@duel.id}'")
    @no_local_lines = Line.where("lines.club_id == '#{@local.id}' AND lines.duel_id == '#{@duel.id}'") 

    if @duel.rival_id.present?
      @guess_lines = Line.where("lines.club_id == '#{@guess.id}' AND lines.status == 1 AND lines.duel_id == '#{@duel.id}'")
      @no_guess_lines = Line.where("lines.club_id == '#{@guess.id}' AND lines.duel_id == '#{@duel.id}'")
    end


    #LOCALS
    @local_members = @local.memberships
    @membership_local = Membership.where(club_id: @local.id)
    @locals = User.where(id: @local_members.map(&:user_id)).where(id: @local_lines.map(&:user_id))
    # @local_users = User.where(id: @local_members.map(&:user_id)).where.not(id: @locals.ids)
    @local_users = User.where(id: @local_members.map(&:user_id))

    #GUESS
    if @duel.rival_id.present?
      @guess_members = @guess.memberships
      @membership_guess = Membership.where(club_id: @guess.id)
      @guesses = User.where(id: @guess_members.map(&:user_id)).where(id: @guess_lines.map(&:user_id))
      # @guess_users = User.where(id: @guess_members.map(&:user_id)).where.not(id: @guesses.ids)
      @guess_users = User.where(id: @guess_members.map(&:user_id))
    end
  end

  def front
  end

  def budget
    add_breadcrumb 'Budget', nil
  end

  def formation
    add_breadcrumb 'Members', members_club_duel_path(@club, @duel)
    add_breadcrumb 'Alignment', nil
    @local = @duel.club
    @guess = Club.find_by(id: @duel.rival_id) if @duel.rival_id.present?

    unless current_user.id == @local.user_id || (@guess&.user_id == current_user.id)
      redirect_back(fallback_location: root_path, alert: "You do not have sufficient authorization for this.")
      return
    end

    @no_approve_clubs = Club.where(id: @duel.rivals.where(approve: false).pluck(:rival_id))
    @approve_clubs = Club.where(id: @duel.rivals.where(approve: true).pluck(:rival_id))

    @local_lines = Line.where(club_id: @local.id, status: 1, duel_id: @duel.id)
    @no_local_lines = Line.where(club_id: @local.id, duel_id: @duel.id)
    @local_lines_approve = Line.where(club_id: @local.id, status: 1, approve: true, duel_id: @duel.id)

    @local_members = @local.memberships
    @locals = User.where(id: @local_members.pluck(:user_id)).where(id: @local_lines.pluck(:user_id))
    @local_users = User.where(id: @local_members.pluck(:user_id))
    @local_users_approved = User.where(id: @local_lines_approve.pluck(:user_id)).where(id: @local_members.pluck(:user_id))
    @local_users_convoked = User.where(id: Line.where(duel_id: @duel.id).pluck(:user_id))

    local_member_ids = @local_members.ids

    @local_us = @local_users 

    if @guess.present?
      @guess_lines = Line.where(club_id: @guess.id, status: 1, duel_id: @duel.id)
      @no_guess_lines = Line.where(club_id: @guess.id, duel_id: @duel.id)

      @guess_members = @guess.memberships
      @guesses = User.where(id: @guess_members.pluck(:user_id)).where(id: @guess_lines.pluck(:user_id))
      @guess_users = User.where(id: @guess_members.pluck(:user_id))
      @guess_users_approved = User.where(id: @guess_lines.where(approve: true).pluck(:user_id))
    end

    @position_choices = User.distinct.pluck(:position)
    @selected_positions = params[:selected_positions] || {}
  end

  def assignment
    @local = @duel.club
    @guess = Club.find_by(id: @duel.rival_id) if @duel.rival_id.present?

    unless current_user.id == @local.user_id || (@guess&.user_id == current_user.id)
      redirect_back(fallback_location: root_path, alert: "You do not have sufficient authorization for this.")
      return
    end

    @no_approve_clubs = Club.where(id: @duel.rivals.where(approve: false).pluck(:rival_id))
    @approve_clubs = Club.where(id: @duel.rivals.where(approve: true).pluck(:rival_id))

    @local_lines = Line.where(club_id: @local.id, status: 1, duel_id: @duel.id)
    @no_local_lines = Line.where(club_id: @local.id, duel_id: @duel.id)
    @local_lines_approve = Line.where(club_id: @local.id, status: 1, approve: true, duel_id: @duel.id)

    @local_members = @local.memberships
    @locals = User.where(id: @local_members.pluck(:user_id)).where(id: @local_lines.pluck(:user_id))
    @local_users = User.where(id: @local_members.pluck(:user_id))
    @local_users_approved = User.where(id: @local_lines_approve.pluck(:user_id)).where(id: @local_members.pluck(:user_id))
    @local_users_convoked = User.where(id: Line.where(duel_id: @duel.id).pluck(:user_id))

    local_member_ids = @local_members.ids

    @local_us = @local_users_approved 

    if @local_users_approved.present?
      # desired_positions = @local_users_approved.pluck(:position).map { |positions| positions.split(',').map(&:strip) }.flatten.uniq
      desired_positions = @local_users_approved

      # @local_available_position = @local_users.select do |user|
      #   position = user.position
      #   if position.present?
      #     positions = position.split(',').map(&:strip)
      #     (positions & desired_positions).any? 
      #   else
      #     false  # O cualquier otro valor predeterminado apropiado
      #   end
      # end
    end
      

    if @guess.present?
      @guess_lines = Line.where(club_id: @guess.id, status: 1, duel_id: @duel.id)
      @no_guess_lines = Line.where(club_id: @guess.id, duel_id: @duel.id)

      @guess_members = @guess.memberships
      @guesses = User.where(id: @guess_members.pluck(:user_id)).where(id: @guess_lines.pluck(:user_id))
      @guess_users = User.where(id: @guess_members.pluck(:user_id))
      @guess_users_approved = User.where(id: @guess_lines.where(approve: true).pluck(:user_id))
    end

    @position_choices = User.distinct.pluck(:position)
    @selected_positions = params[:selected_positions] || {}

    if @duel.formation.present?
      @formacion_actual = @duel.formation
    end


    add_breadcrumb 'Asistencia', members_club_duel_path(@club, @duel)
    add_breadcrumb 'Formación', formation_club_duel_path(@club, @duel)
    add_breadcrumb 'Alineación', nil
  end

  def referee
    @duel = Duel.find(params[:id])

    @referees = Referee.all
    @reservation = Reservation.new

    add_breadcrumb 'Referee', nil
    
  end

  def location
    add_breadcrumb 'Location', nil
  end

  def join
    duel = Duel.find(params[:duel_id])
    rival = Club.find(params[:rival_id])

    @rival = duel.rivals.build(user_id: current_user.id, club_id: @club.id, duel_id: duel.id, rival_id: rival.id, start_date: duel.start_date, end_date: duel.end_date)

    if @rival.save
      flash[:notice] = "You have successfully challenged #{rival.club_name}."
    else
      flash[:alert] = "There was an error challenging #{rival.club_name}."
    end
    redirect_back(fallback_location: request.referer)
  end

  def available_clubs
    # Obtener el equipo actual (current_club)
    current_club = Club.friendly.find(params[:club_id])


    if current_club.latitude.present? && current_club.longitude.present?
      clubs = Club.where(active: true).near([current_club.latitude, current_club.longitude], 10)
      # Excluir el equipo actual de la lista
      clubs - [current_club]
    end
  end

  def rival
  end

  def visuals
    @duel_photos = @duel.duel_photos.with_attached_image
  end

  def joinlines
    @duel = Duel.find(params[:id])
    @club = Club.find(params[:club_id])
    @m = @duel.lines.build(duel_id: params[:id], club_id: params[:club_id], membership: params[:membership_id], user: params[:user_id])
    
    if @m.save
      redirect_back(fallback_location: request.referer, notice: "Called up!")
    else
      flash[:error] = @m.errors.full_messages
      redirect_back(fallback_location: request.referer, alert: "Oops! Something went wrong.")
    end
  end

  def destroy
    @rivals = Rival.where("duel_id = '#{@duel.id}'")
    @reservations = Reservation.where("duel_id = '#{@duel.id}'")

    if @duel.lines.exists?
      redirect_back(fallback_location: request.referer, notice: "You can't delete this duel due to associated lineups!")
    elsif @rivals.exists? 
      redirect_back(fallback_location: request.referer, notice: "You can't delete this duel because there is an existing rival!")
    elsif @reservations.exists?
      Reservation.where(duel_id: @duel.id).destroy_all
      @duel.destroy
      redirect_to club_path(@duel.club), notice: "Duel successfully deleted."
    else
      @duel.destroy
      redirect_to club_path(@duel.club), notice: "Duel successfully deleted."
    end
  end

  def assign_position
    member = User.find(params[:member_id])
    position = params[:position]

    # Actualizar la posición del miembro
    member.update(position: position)

    redirect_back(fallback_location: request.referer)
  end

  def referee_access
    @duel = Duel.find(params[:id])

    # Verifica si el usuario actual es el referee asignado a través de una reserva para este duelo
    @referee = User.joins(reservations: :referee)
                   .where(id: current_user.id, 'reservations.duel_id': @duel.id)
                   .first

    if @referee
      # Acciones permitidas para el referee en este duelo (por ejemplo, mostrar información del duelo)
      render 'referee_access' # Esto renderizará una vista específica para el referee
    else
      redirect_to root_path, alert: 'You do not have access to this duel as a referee.'
    end
  end


  # def duel_progress(duel)
  #   total_progress = 0
  #   total_tasks = 100
  #   total_progress += 20 if duel.avatar.present?
  #   total_progress += 20 if club.services_ready?
  #   total_progress += 10 if club.latitude?
  #   total_progress += 10 if club.longitude?
  #   total_progress += 10 if club.status == 'Published'
  #   total_progress += 10 if Duel.exists?(club_id: club.id)

  #   active_club_ids = current_user.clubs.where(id: @clubs.ids).pluck(:id)
  #   clubs_with_members_count = Club.joins(:memberships)
  #                                   .where(id: active_club_ids, memberships: { status: 1 })
  #                                   .group(:id)
  #                                   .count

  #   total_progress += clubs_with_members_count.keys.count * 20 if clubs_with_members_count[club.id].to_i >= 2

  #   normalized_progress = [total_progress, total_tasks].min
  # end

  

  private

    def set_duel
        @duel = Duel.find(params[:id])
    end
    
    def set_club
      @club = Club.friendly.find(params[:club_id])
    end

    def set_referee
      if @duel.referee_id.present?
        @referee = User.find(@duel.referee_id)
      end
    end


    def create_task
      Task.create(
        description: "Sport Duel",
        start_date: self.start_date,
        end_date: self.end_date,
        user: self.user, 
        club_id: self.club_id, 
        duel_id: self.id
      )
    end

    def available_club_ids
      (available_clubs || []).pluck(:id)
    end

    def set_local_and_guess
      @local = @duel.club
      @guess = Club.find_by(id: @duel.rival_id) if @duel.rival_id.present?
    end

    def is_authorised
      redirect_to root_path, alert: "You do not have sufficient authorization for this." unless current_user.id == @club.user_id
    end

    def set_breadcrumbs
    end

    def authorize_creator
      redirect_to root_path, alert: "You do not have sufficient authorization for this." unless current_user.id == @duel.user_id
    end

    def set_time_zone
      Time.zone = 'UTC'
    end

    def set_formations
      @formaciones = {
                      '4-4-2' => {
                        1 => 'DFI',
                        2 => 'DFCI',
                        3 => 'DFCD',
                        4 => 'DFD',
                        5 => 'MI',
                        6 => 'MCI',
                        7 => 'MCD',
                        8 => 'MD',
                        9 => 'DI',
                        10 => 'DD',
                        11 => 'POR',
                      },

                      '4-3-3' => {
                        1 => 'DFI',
                        2 => 'DFCI',
                        3 => 'DFCD',
                        4 => 'DFD',
                        5 => 'MI',
                        6 => 'MC',
                        7 => 'MD',
                        8 => 'DI',
                        9 => 'DC',
                        10 => 'DD',
                        11 => 'POR'
                      },
                      '4-2-3-1' => {
                        1 => 'DFI',
                        2 => 'DFCI',
                        3 => 'DFCD',
                        4 => 'DFD',
                        5 => 'MI',
                        6 => 'MD',
                        7 => 'EI',
                        8 => 'EC',
                        9 => 'ED',
                        10 => 'DD',
                        11 => 'POR'
                      },

                      '3-5-2' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MCI',
                          6 => 'MC',
                          7 => 'MCD',
                          8 => 'MD',
                          9 => 'DI',
                          10 => 'DD',
                          11 => 'POR'
                      },
                      '4-1-2-1-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'DXC', # DEFENSA EXTREMO CENTRO
                          6 => 'MI',
                          7 => 'MD',
                          8 => 'EC',
                          9 => 'DI',
                          10 => 'DD',
                          11 => 'POR'
                      },
                      '4-3-1-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFD',
                          4 => 'DFCI',
                          5 => 'MI',
                          6 => 'MC',
                          7 => 'MD',
                          8 => 'DC',
                          9 => 'DI',
                          10 => 'DD',
                          11 => 'POR'
                      },
                      '4-3-1-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MC',
                          7 => 'MD',
                          8 => 'EI',  
                          9 => 'DI',  
                          10 => 'DD', 
                          11 => 'POR'
                      },
                      '4-4-1-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MCI',
                          7 => 'MCD',
                          8 => 'MD',
                          9 => 'EC',
                          10 => 'DC', 
                          11 => 'POR'
                      },
                      '5-3-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFC',
                          4 => 'DFCD',
                          5 => 'DFD',
                          6 => 'MI',
                          7 => 'MC',
                          8 => 'MD',
                          9 => 'DI',
                          10 => 'DD', 
                          11 => 'POR'
                      },
                      '4-2-4' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MD',
                          7 => 'DI',
                          8 => 'DCI',
                          9 => 'DCD',
                          10 => 'DD', 
                          11 => 'POR'
                      },
                      '3-4-3' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI', 
                          5 => 'MCI',
                          6 => 'MCD',
                          7 => 'MD', 
                          8 => 'DI', 
                          9 => 'DC', 
                          10 => 'DD',
                          11 => 'POR'
                      },
                      '4-4-1-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MCI',
                          7 => 'MCD',
                          8 => 'MD',
                          9 => 'EC',   
                          10 => 'DC',  
                          11 => 'POR'
                      },
                      '3-5-2' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MCI',
                          6 => 'MC',
                          7 => 'MCD',
                          8 => 'MD',
                          9 => 'DI',   
                          10 => 'DD',  
                          11 => 'POR'
                      },
                      '3-2-4-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MD',
                          6 => 'ECI',
                          7 => 'ECI',
                          8 => 'ECD',
                          9 => 'ED',
                          10 => 'DC',
                          11 => 'POR'
                      },
                      '4-3-2-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MC',
                          7 => 'MD',
                          8 => 'EI',
                          9 => 'ED',
                          10 => 'DC',
                          11 => 'POR'
                      },
                      '3-1-4-2' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'EC',
                          5 => 'MI',
                          6 => 'MCI',
                          7 => 'MCD',
                          8 => 'MD',
                          9 => 'DI',
                          10 => 'DD',
                          11 => 'POR'
                      },
                      '3-2-3-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI', 
                          5 => 'MD',
                          6 => 'ED', 
                          7 => 'EC',
                          8 => 'ED',  
                          9 => 'DC',  
                          11 => 'POR'
                      },
                      '4-1-2-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'DXC', 
                          6 => 'MI',
                          7 => 'MD',
                          8 => 'DI',  
                          9 => 'DC',  
                          11 => 'POR'
                      },
                      '3-3-2-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',   
                          5 => 'MC',   
                          6 => 'MD',   
                          7 => 'EI',   
                          8 => 'ED',   
                          9 => 'DC',   
                          11 => 'POR',
                      },
                      '3-4-1-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI', 
                          5 => 'MCI',
                          6 => 'MCD', 
                          7 => 'MD',
                          8 => 'EC',  
                          9 => 'DC',  
                          11 => 'POR'
                      },
                      '3-2-2-2' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'EI', 
                          5 => 'ED', 
                          6 => 'MI',  
                          7 => 'MD',  
                          8 => 'DI',  
                          9 => 'DD',  
                          11 => 'POR'
                      },
                      '4-2-1-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'EI',
                          6 => 'ED',
                          7 => 'MC', 
                          8 => 'DI', 
                          9 => 'DC', 
                          10 => 'DD',
                          11 => 'POR'
                      },
                      '3-3-2-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MC',
                          6 => 'MD',
                          7 => 'EI',
                          8 => 'EC',
                          9 => 'DC',
                          11 => 'POR'
                      },
                      '4-3-1-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MC',
                          7 => 'MD',
                          8 => 'EC',  
                          9 => 'DC',   
                          11 => 'POR'
                      },
                      '4-1-3-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MC',
                          6 => 'EI',
                          7 => 'EC',
                          8 => 'ED',
                          9 => 'DC',
                          11 => 'POR'
                      },
                      '3-3-2-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MC',
                          6 => 'MD',
                          7 => 'EI',
                          8 => 'ED',
                          9 => 'DC', 
                          11 => 'POR',
                      },
                      '4-3-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MC',
                          7 => 'MD',
                          8 => 'DI',
                          9 => 'DC',
                          11 => 'POR', 
                      },
                      '3-4-2' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MCI',
                          6 => 'MCD',
                          7 => 'MD',
                          8 => 'DI',
                          9 => 'DD',
                          11 => 'POR',
                      },
                      '3-2-2-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI', 
                          5 => 'MD', 
                          6 => 'EI', 
                          7 => 'ED', 
                          8 => 'DC', 
                          11 => 'POR',
                      },
                      '2-3-1-2' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI',   
                          4 => 'MC',  
                          5 => 'MD',  
                          6 => 'EC',   
                          7 => 'DI',   
                          8 => 'DC',   
                          11 => 'POR',
                      },
                      '4-2-1-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',   
                          5 => 'MI',   
                          6 => 'MD',   
                          7 => 'EC',   
                          8 => 'DC',   
                          11 => 'POR',
                      },
                      '2-4-1-1' => {
                          1 => 'DFI',
                          2 => 'DFD',   
                          3 => 'MI',   
                          4 => 'MCI',   
                          5 => 'MCD',   
                          6 => 'MD',    
                          7 => 'EC',    
                          8 => 'DC',    
                          11 => 'POR',
                      },
                      '3-1-3-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MC',
                          5 => 'EI',
                          6 => 'EC',
                          7 => 'ED',
                          8 => 'DC',
                          11 => 'POR',
                      },
                      '2-2-3-1' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI',   
                          4 => 'MD',  
                          5 => 'EI',  
                          6 => 'EC',   
                          7 => 'ED',   
                          8 => 'DC',   
                          10 => 'POR',
                      },
                      '4-2-2' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MD',
                          7 => 'MD',
                          8 => 'MC',
                          9 => 'DI',   
                          10 => 'DD',  
                          11 => 'POR',
                      },
                      '2-4-2' => {
                          1 => 'DFI',
                          2 => 'DFD',   
                          3 => 'MI',   
                          4 => 'MCI',   
                          5 => 'MCD',   
                          6 => 'MD',    
                          7 => 'DI',    
                          8 => 'DD',    
                          11 => 'POR',
                      },
                      '3-1-2-1-1' => {
                          1 => 'DFI',
                          2 => 'DFC', 
                          3 => 'DFD',
                          4 => 'MI',  
                          5 => 'MCI', 
                          6 => 'MD',  
                          7 => 'DC',  
                          8 => 'DI',  
                          11 => 'POR',
                      },
                      '3-2-2' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MD',
                          6 => 'DC',
                          7 => 'DD',
                          11 => 'POR',
                      },
                      '2-3-1-1' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI',
                          4 => 'MCI',
                          5 => 'MCD',
                          6 => 'EC',
                          7 => 'DC',
                          11 => 'POR',
                      },
                      '3-2-1-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MD',
                          6 => 'EC',
                          7 => 'DC',
                          11 => 'POR',
                      },
                      '4-2-1' => {
                          1 => 'DFI',
                          2 => 'DFCI',
                          3 => 'DFCD',
                          4 => 'DFD',
                          5 => 'MI',
                          6 => 'MD',
                          7 => 'DC',
                          11 => 'POR',
                      },
                      '2-4-1' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI',
                          4 => 'MCI',
                          5 => 'MCD',
                          6 => 'MD',
                          7 => 'DC',
                          11 => 'POR',
                      },
                      '3-3-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MI',
                          5 => 'MC',
                          6 => 'MD',
                          7 => 'DC',
                          11 => 'POR',
                      },
                      '3-1-3' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MC',
                          5 => 'DI',
                          6 => 'DC',
                          7 => 'DD',
                          11 => 'POR',
                      },
                      '2-2-3' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI',
                          4 => 'MD',
                          5 => 'DI',
                          6 => 'DC',
                          7 => 'DD',
                          11 => 'POR',
                      },
                      '1-4-2' => {
                          1 => 'DC',
                          2 => 'MI',
                          3 => 'MCI',
                          4 => 'MCD',
                          5 => 'MD',
                          6 => 'DI',
                          7 => 'DD',
                          11 => 'POR',
                      },
                      '3-1-2-1' => {
                          1 => 'DFI',
                          2 => 'DFC',
                          3 => 'DFD',
                          4 => 'MC',
                          5 => 'EI',
                          6 => 'ED',
                          7 => 'DC',
                          11 => 'POR',
                      },
                      '2-2-2' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI',
                          4 => 'MD',
                          5 => 'DI',
                          6 => 'DD',
                          11 => 'POR',
                      },
                      '1-2-1-2' => {
                          1 => 'DFC',
                          2 => 'MI', 
                          3 => 'MD', 
                          4 => 'EC', 
                          5 => 'DI', 
                          6 => 'DD', 
                          11 => 'POR'
                      },
                      '2-2-1-1' => {
                          1 => 'DFI',
                          2 => 'DFD',
                          3 => 'MI', 
                          4 => 'MD', 
                          5 => 'EC',
                          6 => 'DC', 
                          11 => 'POR'
                      },
                      '1-3-2' => {
                        1 => 'DFC',    
                        2 => 'MI',     
                        3 => 'MC',    
                        4 => 'MD',    
                        5 => 'DI',     
                        6 => 'DD',     
                        11 => 'POR',   
                      },
                      '3-1-2' => {
                        1 => 'DFI',  
                        2 => 'DFC',  
                        3 => 'DFD',  
                        4 => 'MC',   
                        5 => 'DI',   
                        6 => 'DC',   
                        7 => 'DD',   
                        11 => 'POR', 
                      },
                      '1-2-2-1' => {
                        1 => 'DFC',  
                        2 => 'MI',   
                        3 => 'MD',   
                        4 => 'EI',   
                        5 => 'ED',   
                        5 => 'DC',   
                        11 => 'POR', 
                      },
                      '2-1-2-1' => {
                        1 => 'DFI',   
                        2 => 'DFD',   
                        3 => 'MC',    
                        4 => 'EI',    
                        5 => 'ED',     
                        6 => 'DC',     
                        11 => 'POR',   
                      },
                      '3-1-1-1' => {
                        1 => 'DFI',    
                        2 => 'DFC',    
                        3 => 'DFD',    
                        4 => 'MC',     
                        5 => 'EC',     
                        6 => 'DC',     
                        11 => 'POR',  
                      },
                      '2-1-1-2' => {
                        1 => 'DFI',  
                        2 => 'DFD',  
                        3 => 'MC',   
                        4 => 'EC',    
                        5 => 'DI',    
                        6 => 'DD',    
                        11 => 'POR', 
                      },

                      '2-2-1' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'MI',
                        4 => 'MD',
                        5 => 'DC',
                        11 => 'POR',
                      },
                      '1-3-1' => {
                        1 => 'DFC',
                        2 => 'MI',
                        3 => 'MC',
                        4 => 'MD',
                        5 => 'DC',
                        11 => 'POR',
                      },
                      '2-1-2' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'MC',
                        4 => 'DI',
                        5 => 'DD',
                        11 => 'POR',
                      },
                      '3-2' => {
                        1 => 'DFI',
                        2 => 'DFC',
                        3 => 'DFD',
                        4 => 'DI',
                        5 => 'DD',
                        11 => 'POR',
                      },
                      '2-3' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'DI',
                        4 => 'DC',
                        5 => 'DD',
                        11 => 'POR',
                      },
                      '3-1-1' => {
                        1 => 'DFI',
                        2 => 'DFC',
                        3 => 'DFD',
                        4 => 'MC',
                        5 => 'DC',
                        11 => 'POR',
                      },
                      '1-1-3' => {
                        1 => 'DFC',
                        2 => 'MC',
                        3 => 'DI',
                        4 => 'DC',
                        5 => 'DD',
                        11 => 'POR',
                      },
                      '1-2-2' => {
                        1 => 'DFC',
                        2 => 'MI',
                        3 => 'MD',
                        4 => 'DI',
                        5 => 'DD',
                        11 => 'POR',
                      },
                      '2-1-1-1' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'MC',
                        4 => 'EC',
                        5 => 'DC',
                        11 => 'POR',
                      },
                      '1-1-2-1' => {
                        1 => 'DFC',
                        2 => 'MC',
                        3 => 'EI',
                        4 => 'ED',
                        5 => 'DC',
                        11 => 'POR',
                      },
                      '1-1-1-2' => {
                        1 => 'DFC',
                        2 => 'MC',
                        3 => 'EC',
                        4 => 'DI',
                        5 => 'DD',
                        11 => 'POR',
                      },
                      '1-2-1-1' => {
                        1 => 'DFC',
                        2 => 'MI',
                        3 => 'MD',
                        4 => 'EC',
                        5 => 'DC',
                        11 => 'POR',
                      },

                      '2-2' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'DI',
                        4 => 'DD',
                        11 => 'POR',
                      },
                      '1-3' => {
                        1 => 'DFC',
                        2 => 'DI',
                        3 => 'DC',
                        4 => 'DD',
                        11 => 'POR',
                      },
                      '2-1-1' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'MC',
                        4 => 'DC',
                        11 => 'POR',
                      },
                      '3-1' => {
                        1 => 'DFI',
                        2 => 'DFC',
                        3 => 'DFD',
                        4 => 'DC',
                        11 => 'POR',
                      },
                      '1-2-1' => {
                        1 => 'DFC',
                        2 => 'MI',
                        3 => 'MD',
                        4 => 'DC',
                        11 => 'POR',
                      },
                      '2-1-1' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'MC',
                        4 => 'DC',
                        11 => 'POR',
                      },
                      '1-1-2' => {
                        1 => 'DFC',
                        2 => 'MC',
                        3 => 'DI',
                        4 => 'DD',
                        11 => 'POR',
                      },
                      '2-1' => {
                        1 => 'DFI',
                        2 => 'DFD',
                        3 => 'DC',
                        11 => 'POR',
                      },
                      '1-2' => {
                        1 => 'DFC',
                        2 => 'DI',
                        3 => 'DD',
                        11 => 'POR',
                      },
                      '3' => {
                        1 => 'DFI',
                        2 => 'DFC',
                        3 => 'DFD',
                        11 => 'POR',
                      },
                      '1-1' => {
                        1 => 'DFC',
                        2 => 'DC',
                      },
                      '2' => {
                        1 => 'DFI',
                        2 => 'DFD',
                      },
                      '1' => {
                        1 => 'DFC'
                      },
                      
      }
    end

    def duel_params
      params.require(:duel).permit( :duel_type, :height, :members, :duration, :duration_time, 
                                    :duration_goals, :goals, :place, :place_type, :referee, :referee_name, :referee_type, 
                                    :lockers, :showerbaths, :bathrooms, :audience, :audience_type, :name, :location, :listing, 
                                    :summary, :is_internet, :refreshment, :refreshment_summary, :active, :status, :duel_class, 
                                    :price, :sport, :sport_type, :private, :country, :city, :address, :parking, :start_date, 
                                    :end_date, :neighborhood, :city, :country, :budget, :budget_place, :budget_equipment, 
                                    :sport_bib, :digital_counter,:streaming, :snacks, :referee_price, :referee_freelance, 
                                    :club_id, :user_id, :rival_id, :duel_total,:local_score, :rival_score, :referee_id, 
                                    :latitude, :longitude, :responsibility, :substitutes, :formation, :serviceconfirmation, 
                                    :showformation, :time_type, :ready_time, :color_local, :color_rival, :hunted)
    end
end
