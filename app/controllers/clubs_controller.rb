class ClubsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :clubname_validator, :answer]
  before_action :set_club, except: [:index, :new, :create, :clubname_validator, :sendjoin]
  before_action :set_user, except: [:index, :new, :create, :show, :sendjoin]
  before_action :set_breadcrumbs, except: [:index, :new, :create]
  before_action :is_authorised, only: [:leader, :description, :members, :visuals, :budget, :amenities, :location, :notifications]

  def index
    @clubs = Club.all
  end

  def new
    @club = current_user.clubs.build
  end

  def create
    # user = User.friendly.find(params[:user_id])
    @club = current_user.clubs.build(club_params)
    @club.status = "Unpublished"


    # Crear un nuevo Membership asociado al usuario actual (current_user)
    @membership = Membership.new(user_id: current_user.id, club: @club, firstname: current_user.firstname, lastname: current_user.lastname, active: true, status: 1, position: 'OWNER', number: 00, maker_id: current_user.id)

    if @club.save && @membership.save
      redirect_to edit_club_path(@club), notice: "¡Hecho!"
    else
      render :new, notice: "Ups, algo esta mal"
    end
  end

  def update
    old_slug = @club.slug # guardar el slug antiguo
    
    if @club.update(club_params)
      new_slug = @club.slug # guardar el nuevo slug

      # comparar los valores del slug antiguo y nuevo
      if old_slug != new_slug
        flash[:notice] = "¡Guardado!"
        redirect_to edit_club_path(@club), notice: "¡Hecho!"
      else
        flash[:notice] = "El slug no ha sido actualizado"
        redirect_to edit_club_path(@club), notice: "¡Hecho!"
      end
    else
      flash[:notice] = "Algo no esta bien"
      redirect_to edit_club_path(@club), notice: "¡Hecho!"
    end
  end

  def show
    @memberships = @club.memberships
    @photos = @club.club_photos
    @members = User.all.joins(:memberships).where("'#{@club.id}' == memberships.club_id AND users.id = memberships.user_id AND memberships.status = 1")
    # Calcula el progreso del club (este es solo un ejemplo, tendrás que adaptarlo a tus necesidades)
    @club.progress_percentage = calculate_progress(@club)
    
    @tasks = Task.where(club_id: @club.id)
  end

  def dashboard
      
    load_user_clubs
    load_notifications
    load_duels_and_related_info
    load_opponent_info

    # @clubs = current_user.clubs
    # @notifications = current_user.notifications.order(created_at: :desc)

    # @duels_for_user = Duel.where("club_id = :club_id OR rival_id = :club_id", club_id: @club.id)

    # @opponent_duels = @duels_for_user.where.not(club_id: @club.id).or(@duels_for_user.where.not(rival_id: @club.id))

    # @opponent = Club.find_by(id: @opponent_duels.pluck(:club_id, :rival_id).flatten.uniq.compact.first)
  end

  def description
  end

  def edit
    @club_photos = @club.club_photos
  end

  def members
    # @m = @membership.update(active: true)
    @memberships = @club.memberships
    @notifications = current_user.notifications.order(created_at: :desc)
    @news = @notifications.where(club_id: @club.id).limit(3)

    @members = User.joins(:memberships).where("memberships.club_id == '#{@club.id}' AND users.id == memberships.user_id AND memberships.status == 1")
    @no_members = User.joins(:memberships).where("memberships.club_id == '#{@club.id}'").where("users.id == memberships.user_id AND memberships.status == 0 AND memberships.maker_id != '#{current_user.id}'")
    @declins = User.joins(:memberships).where("memberships.club_id == '#{@club.id}'").where("users.id == memberships.user_id AND memberships.status == 2")

    load_membership_data
    load_approved_memberships
  end

  def welfare
  end

  def location
  end

  def duels
    load_duels_and_related_info
    set_event_times
    set_event_time2 if @previa
    set_event_time1 if @soonduel
  end

  def scouting
    load_user_data
    load_club_data
    load_membership_data
    load_approved_memberships
    load_rejected_memberships
    load_member_clubs

    prepare_players_list

  end

  def jointrue
    @members = User.all.joins(:memberships).where("'#{@club.id}' == memberships.club_id AND users.id = memberships.user_id AND memberships.active = true")
    @no_members = User.all.joins(:memberships).where("'#{@club.id}' == memberships.club_id AND users.id = memberships.user_id AND memberships.active = false")

    @ships = @club.memberships.where(club_id: @club.id).where(user_id: @no_members.ids)
    # @membership = Membership.where(club_id: @club.id).where(user_id: @user.id)
    
    if @ships.update(active: true)
      flash[:notice] = "¡Guardado!"
    else
      flash[:notice] = "Algo no esta bien"
    end
    redirect_back(fallback_location: request.referer)
  end

  def join
    @club = Club.friendly.find(params[:id])
    @m = @club.memberships.build(user_id: current_user.id, slug: current_user.slug, firstname: current_user.firstname, lastname: current_user.lastname, position: current_user.position, number: current_user.number)
    
    respond_to do |format|
      if @m.save
        Notification.create(recipient: @club.user, notification_type: 'solicitude', sender: current_user, content: "Tienes una nueva solicitud para #{@club.club_name.upcase} de #{current_user.firstname.capitalize} #{current_user.lastname.capitalize}.", url: members_club_path(@club.id), club_id: @club.id, category: 2, action: 5)
        format.html { redirect_to(@club, :notice => '¡Leyenda! Pronto recibirás una respuesta del capitan') }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@club, :alert => 'Ops! Intenta mas tarde') }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  def sendjoin
    @club = Club.find(params[:club_id])
    @user = User.find(params[:user_id]) # El ID del usuario al que se le envía la invitación
    @membership = @club.memberships.build(user_id: @user.id, slug: @user.slug, firstname: @user.firstname, lastname: @user.lastname, position: @user.position, number: @user.number, maker_id: current_user.id)

    respond_to do |format|
      if @membership.save
        Notification.create(
          recipient: @user,
          notification_type: 'solicitude',
          sender: current_user,
          content: "Has sido invitado a unirte a #{@club.club_name.upcase} por la dirección de  #{current_user.firstname.capitalize}.",
          url:  club_membership_path(@club, @membership),
          club_id: @club.id,
          user_id: @user.id,
          category: 2,
          action: 5
        )
        format.html { redirect_back(fallback_location: request.referer, notice: 'Invitación enviada correctamente') }
        format.xml { head :ok }
        format.js
      else
        format.html { redirect_back(fallback_location: request.referer, alert: 'Ocurrió un error al enviar la invitación') }
        format.xml { render xml: @club.errors, status: :unprocessable_entity }
        format.js { render 'error', status: :unprocessable_entity } 
      end
    end

  end

  def notifications
    @notifications = current_user.notifications.order(created_at: :desc)
    @news = @notifications.where(club_id: @club.id)
  end

  def mark_all_as_read
    @news = @notifications.where(club_id: @club.id).to_a
    @news.each do |notification|
      notification.update(read_at: Time.current)
    end

    redirect_back(fallback_location: request.referer)
  end

  def clubname_validator
      if params[:slug].size <= 2
        render json: { valid: false }
      elsif Club.find_by_slug(params[:slug].downcase) || Club.find_by_slug(params[:slug].upcase)
        render json: { valid: false }
      elsif params[:slug].match(/\s/) || !params[:slug].match(/\A[a-zA-Z0-9]+\Z/)
        render json: { valid: false }
      elsif !params[:slug].match(params[:slug].downcase)
        render json: { valid: false }
      elsif params[:slug] == 'google' || params[:slug] == 'amazon' || params[:slug] == 'youtube' || 
          params[:slug] == 'facebook' || params[:slug] == 'twitter' || params[:slug] == 'apple' || 
          params[:slug] == 'billgates' || params[:slug] == 'stevejobs' || params[:slug] == 'fifa'|| 
          params[:slug] == 'jeffbezos' || params[:slug] == 'elonmusk' || params[:slug] == 'tesla' || 
          params[:slug] == 'nikolatesla' || params[:slug] == 'mockering' || params[:slug] == 'mocker' ||
          params[:slug] == 'mocking' || params[:slug] == 'corona' || params[:slug] == 'profile' || 
          params[:slug] == 'login' || params[:slug] == 'logout' || params[:slug] == 'sign_in' ||
          params[:slug] == 'michaeljackson' || params[:slug] == 'beats' || params[:slug] == 'messi'|| 
          params[:slug] == 'auronplay' || params[:slug] == 'rubius' || params[:slug] == 'luisitocomunica' || 
          params[:slug] == 'bahamon' || params[:slug] == 'cristiano' || params[:slug] == 'ronaldo' ||
          params[:slug] == 'intel' || params[:slug] == 'amd' || params[:slug] == 'ryzen' || params[:slug] == 'gamer'
        render json: {valid:false}
      else
        render json: { valid: true }
      end
  end

  def delete
    @club = Club.friendly.find(params[:id])

    if @club.destroy
      flash[:notice] = "¡El club ha sido eliminado con éxito!"
      redirect_to clubs_path
    else
      flash[:alert] = "No se pudo eliminar el club. Por favor, inténtalo de nuevo."
      redirect_to club_path(@club)
    end
  end



  private

    def set_club
        @club = Club.friendly.find(params[:id])
    end

    def set_user
        @user = User.find(current_user.id)
    end

    def set_breadcrumbs
    end

    def load_duels_and_related_info
      @next = load_next_duel
      @open = load_open_duel
      @duel = load_current_duel
      @undo = load_pending_duel
      @duels = load_all_relevant_duels
      @pasts = load_past_duels
      @other_duels = load_other_duels
      @members = load_members_club
      @notifications = current_user.notifications.order(created_at: :desc)
      @news = @notifications.where(club_id: @club.id).limit(3)

      @soonduel = load_soon_duel
      @previa = load_previa_duel
      @duels = load_past_and_current_duels
      @unpublished_duels = load_unpublished_duels

      @locals = Duel.where(club_id: @club.id, active: true)
      @guesses = Duel.where(rival_id: @club.id, active: true)

      @requested_rivals = @club.rivals.where(club_id: @club.id)
      @approved_requested_rivals = @requested_rivals.where(approve: true)
      @rejected_requested_rivals = @requested_rivals.where(approve: false)
    end


    #DASHBOARD
      def load_user_clubs
        @clubs = current_user.clubs
      end

      def load_notifications
        @notifications = current_user.notifications.order(created_at: :desc)
      end

      def load_opponent_info
        @duels_for_user = Duel.where("club_id = :club_id OR rival_id = :club_id", club_id: @club.id)
        @opponent_duels = @duels_for_user.where.not(club_id: @club.id).or(@duels_for_user.where.not(rival_id: @club.id))
        @opponent = Club.find_by(id: @opponent_duels.pluck(:club_id, :rival_id).flatten.uniq.compact.first)
      end


    # DUELS

      def load_soon_duel
        Duel.where("club_id = ? AND active = ? AND start_date > ? AND rival_id IS NOT NULL", @club.id, true, DateTime.now).order(:start_date).first
      end

      def load_previa_duel
        Duel.where("club_id = ? AND active = ? AND start_date > ? AND rival_id IS NULL", @club.id, true, DateTime.now).order(:start_date).first
      end

      def load_past_and_current_duels
        Duel.where("(club_id = ? OR rival_id = ?) AND active = ? AND start_date < ?", @club.id, @club.id, true, DateTime.now).order(start_date: :desc)
      end

      def load_unpublished_duels
        Duel.where("club_id = ? AND active = ? AND rival_id IS NULL AND start_date > ?", @club.id, true, DateTime.now).order(:start_date)
      end

      def set_event_times
        set_event_time_for_previa_duel if @previa
        set_event_time_for_soon_duel if @soonduel
      end

      def set_event_time_for_previa_duel
        time_remaining = @previa.start_date - DateTime.now
        # Lógica para establecer el tiempo restante para el evento previa
      end

      def set_event_time_for_soon_duel
        time_remaining = @soonduel.start_date - DateTime.now
        # Lógica para establecer el tiempo restante para el evento soonduel
      end

      def load_next_duel
        Duel.where("(club_id = ? OR rival_id = ?) AND start_date > ?", @club.id, @club.id, DateTime.now)
            .where.not(rival_id: nil)
            .order(:start_date)
            .first
      end

      def load_open_duel
        Duel.where("(club_id = ? OR rival_id = ?) AND status = ?", @club.id, @club.id, Duel.statuses[:Open]).order(:start_date).first
      end

      def load_current_duel
        Duel.where("(club_id = :club_id OR rival_id = :club_id) AND status = :approved AND start_date <= :now AND end_date >= :now", 
                      club_id: @club.id, 
                      approved: Duel.statuses[:Approved],
                      now: DateTime.now)
               .order(start_date: :desc)
               .first
      end

      def load_pending_duel
        Duel.where("club_id = :club_id AND status = :pending",
                    club_id: @club.id,
                    pending: Duel.statuses[:Pending])
            .order(:start_date)
            .first
      end
      
      def load_all_relevant_duels
        duels_excluded = [@next&.id, @open&.id, @duel&.id, @undo&.id].compact
        Duel.where.not(id: duels_excluded)
            .where("(club_id = :club_id OR rival_id = :club_id) AND status = :approved",
                   club_id: @club.id,
                   approved: Duel.statuses[:Approved])
            .where("start_date >= ?", DateTime.now.beginning_of_day)
            .order(:start_date)
      end

      def load_past_duels
        Duel.where.not(id: [@next&.id, @open&.id, @duel&.id, @undo&.id, *@duels_ids].compact)
            .where("(club_id = :club_id OR rival_id = :club_id) AND (status IN (:statuses)) AND (end_date < :current_date)", 
                  club_id: @club.id,
                  statuses: [Duel.statuses[:Done], Duel.statuses[:Expired]],
                  current_date: DateTime.now)
            .order(:start_date)
      end
      
      def load_members_club
        User.joins(:memberships).where("memberships.club_id == '#{@club.id}' AND users.id == memberships.user_id AND memberships.status == 1").limit(10)
      end

      def load_other_duels
        Duel.where("club_id = ? AND id NOT IN (?)", @club.id, [@next&.id, @open&.id].compact).order(start_date: :desc)
      end

      def calculate_progress(club)
      end

      def set_event_time1
        time_remaining1 = @soonduel.start_date - DateTime.now
        # Remaining logic for setting event time for @event_time1
      end

      def set_event_time2
        time_remaining2 = @previa.start_date - DateTime.now
        # Remaining logic for setting event time for @event_time2
      end
      
      def calculate_event_time(event)
        time_remaining = event.start_date - DateTime.now
        # Lógica para calcular el tiempo restante y retornar el formato deseado
      end

    # SCOUTING

      def load_user_data
        @users = User.all
      end

      def load_club_data
        @clubs = current_user.clubs
      end

      def load_membership_data
        @lines = Line.where(user_id: current_user.id, approve: 1)
        @memberships = Membership.where(user_id: current_user.id, status: 1)
        @pendings = Membership.where(club_id: @club.id, status: 0)
      end

      def load_approved_memberships
        @approveds = Membership.where(club_id: @club.id, status: 1)
      end

      def load_rejected_memberships
        @rejecteds = Membership.where(club_id: @club.id, status: 2)
      end

      def load_member_clubs
        @memberclubs = Club.joins(:memberships).where(memberships: { id: @memberships.pluck(:id) })
      end

      def prepare_players_list
        approved_user_ids = @approveds.pluck(:user_id)
        @players = @users - [current_user] - User.where(id: approved_user_ids)
      end

    def is_authorised
      redirect_to club_path, alert: "No tienes suficiente autorización" unless current_user.id == @club.user_id
    end

    def club_params
      params.require(:club).permit( :club_name, :country, :city, :sport, :sport_type, 
                                    :members, :location, :summary, :active,  :address,
                                    :status, :price, :private, :uniform, :slug, :captain, :avatar, :training,
                                    :hydration, :owner, :lockers, :snacks, :payroll, :bathrooms, :staff, :assistance,
                                    :roof, :parking, :wifi, :gym, :amenities, :lunch, :transport, :showers,
                                    :latitude, :longitude, :neighborhood, :videogames, :air, :pools, :perdiem, :heating, 
                                    :washers, :courses, :payment, :services_ready)
    end

end
