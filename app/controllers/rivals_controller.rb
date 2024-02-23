class RivalsController < ApplicationController
  before_action :set_club
  before_action :set_duel
  before_action :set_rival, except: [:index, :new, :create, :challenge]
  before_action :is_authorised, only: [:edit]
  before_action :authenticate_user!, except: [:show]

  def available_clubs
    # Obtener el equipo actual (current_club)
    current_club = Club.friendly.find(params[:club_id])

    if current_club.latitude.present? && current_club.longitude.present?
      # Obtener los equipos activos y cercanos (por ejemplo, en un radio de 10 km)
      clubs = Club.where(active: true).near([current_club.latitude, current_club.longitude], 10)

      # Excluir el equipo actual de la lista
      clubs - [current_club]
    end
  end

  def index
    @rivals = @duel.rivals
    @reservation = Reservation.new
    @invitation = Invitation.new
    @rival = Club.where(id: @duel.rival_id)

    challenger_club_ids = @rivals.where(duel_id: @duel.id).pluck(:rival_id)

    @unchallengers = Club.where(id: challenger_club_ids).paginate(page: params[:page], per_page: 10)
    challenger_ids = @unchallengers.pluck(:id)

    if available_clubs.present?
      available_club_ids = available_clubs.pluck(:id) - challenger_ids
      @available_clubs = Club.where(id: available_club_ids).paginate(page: params[:page], per_page: 10)
    end
    # Obtiene los IDs de los usuarios dueños de esos equipos desafiados
    sender_user_ids = Club.where(id: challenger_club_ids).pluck(:user_id)

    # Obtiene los registros de usuarios basados en los IDs obtenidos
    @sender_users = User.where(id: sender_user_ids)

    @local = Club.where("clubs.id = '#{@duel.club_id}'").first 
    if @duel.rival_id.present?
      @guess = Club.where("clubs.id = '#{@duel.rival_id}'").first
    end
  end
 
  def new
    @rival = @duel.rivals.new
  end

  def create
    user = current_user
    club = Club.friendly.find(params[:club_id])
    duel = Duel.find(params[:duel_id])

    @rival = @duel.rivals.build(rival_params)
    @rival.user = user
    @rival.club = club
    @rival.duel = duel
    @rival.save
    
    if @rival.save
      render :show, notice: "Done!"
    else
      render :new, notice: "Oops! Something went wrong."
    end
  end

  def update
    if @rival.update(rival_params)
      flash[:notice] = "Saved!"
    else
      flash[:notice] = "Oops! Something went wrong."
    end
    redirect_back(fallback_location: request.referer)
  end

  def edit
    if @rival.update(rival_params)
      flash[:notice] = "Saved!"
    else
      flash[:notice] = "Oops! Something went wrong."
    end
    redirect_back(fallback_location: request.referer)
  end
  
  def show
  end

  def join
    user = current_user
    club = Club.friendly.find(params[:club_id])
    duel = Duel.find(params[:duel_id])
    rival = Duel.find(params[:rival_id])
    @r = duel.rivals.build(user_id: user.id, club_id: club.id, duel_id: duel.id, rival_id: rival.id, start_date: duel.start_date, end_date: duel.end_date)
    
    respond_to do |format|
      if @r.save
        # Notification.create(recipient: @club.user, notification_type: 'solicitude', sender: current_user, content: "Tienes una nueva solicitud para #{@club.club_name} de #{current_user.slug.capitalize}.", url: members_club_path(@club.id), club_id: @club.id, category: 2, action: 5)
        format.html { redirect_to(@club, :notice => "Awesome! You'll soon receive a response from the captain.") }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@club, :alert => 'Oops! Something went wrong.') }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  def challenge
    duel = Duel.find(params[:duel_id])
    rival = Club.find(params[:rival_id])

    @rival = duel.rivals.build(user_id: current_user.id, club_id: @club.id, duel_id: duel.id, rival_id: rival.id, start_date: duel.start_date, end_date: duel.end_date)

    if @rival.save
      flash[:notice] = "You have challenged #{rival.club_name}."
      Notification.create(recipient: rival.user, notification_type: 'challenge', sender: current_user, content: "#{@club.club_name} has challenged you!", url: club_duel_rival_path(@club, duel, @rival), club_id: @club.id, category: 1, action: 1)
    else
      flash[:alert] = "There was an error challenging #{rival.club_name}."
    end
    redirect_back(fallback_location: request.referer)
  end

  def show
    @current_user = current_user

    # Encuentra el Rival actual
    @rival = Rival.find(params[:id])

    # Encuentra el club relacionado con el Rival.rival_id
    club_associated_with_rival = Club.find(@rival.rival_id)

    # Verifica si el usuario actual es el propietario del club asociado
    if club_associated_with_rival.user_id == @current_user.id
      @user_has_permission = true
    else
      @user_has_permission = false
    end
  end



  private

    def set_rival
        @rival = Rival.find(params[:id])
    end

    def set_duel
        @duel = Duel.find(params[:duel_id])
    end
    
    def set_club
        @club = Club.friendly.find(params[:club_id])
    end
    
    def set_guess
        @guess = Club.friendly.find(params[:rival_id])
    end

    def is_authorised
      redirect_to root_path, alert: "You do not have sufficient authorization for this."
    end

    def rival_params
      params.require(:rival).permit(:status, :approve, :rival_id, :club_id, :user_id, :duel_id, :duel_total)
    end
end
