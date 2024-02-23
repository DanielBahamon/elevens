class ReservationsController < ApplicationController

  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_club, except: [:index]
  before_action :set_duel, except: [:index, :new, :create]
  before_action :set_time, except: [:index, :new, :create]
  before_action :set_reservation, except: [:index, :new, :create, :reply]
  before_action :is_authorised, only: [:reply, :show]


  def create
    @duel = Duel.find(params[:duel_id])
    @club = Club.find(@duel.club_id)
    local = Club.find_by(id: @duel.club_id)
    if @duel.rival_id.present?
      rival = Club.find_by(id: @duel.rival_id)
    end 
    
    if local && rival
      @referees = Referee.all.where.not(user_id: Membership.where(club_id: [local.id, rival.id].compact).pluck(:user_id))
    else
      @referees = Referee.all.where.not(user_id: Membership.where(club_id: local&.id).pluck(:user_id))
    end

    # Crear una reserva para cada árbitro si aún no existe
    @referees.each do |referee|
      next if Reservation.exists?(duel_id: @duel.id, referee_id: referee.id)

      start_time = Time.parse(params.require(:reservation)[:start_date])
      end_time = Time.parse(params.require(:reservation)[:end_date])
      duration_minutes = (end_time.to_time - start_time.to_time).to_i / 60
      referee_price_per_minute = referee.price.to_i / 60.0
      total_amount = referee_price_per_minute * duration_minutes

      @reservation = current_user.reservations.build(reservation_params)
      @reservation.duel = @duel
      @reservation.referee = referee
      @reservation.position = referee.position
      @reservation.price = referee.price
      @reservation.total = total_amount.round(2)

      if @reservation.save
        flash[:notice] = "Sent!"
        Notification.create(
          recipient: referee.user,
          notification_type: 'solicitude',
          sender: current_user,
          content: "#{current_user.slug.capitalize} has invited you to be a referee in a match.",
          url: club_duel_reservation_path(@club, @duel, @reservation),
          club_id: @club.id,
          category: 8,
          action: 10
        )
      else
        flash[:alert] = "Oops! Something went wrong."
        redirect_back(fallback_location: request.referer)
        return
      end
    end
    if user_signed_in?
      redirect_back(fallback_location: request.referer)
    else
      redirect_back(fallback_location: request.referer)
    end
  end



  # def create
  #   @duel = Duel.find(params[:duel_id])
  #   @referees = Referee.all # Obtener todos los árbitros disponibles

  #   # Seleccionar un árbitro al azar de la lista
  #   referee = @referees.sample

  #   @reservation = current_user.reservations.build(reservation_params)
  #   @reservation.duel = @duel
  #   @reservation.referee = referee
  #   # Resto del código para configurar la reserva...

  #   if @reservation.save
  #     flash[:notice] = "Solicitud enviada"
	#     Notification.create(
	#       recipient: referee.user,
	#       notification_type: 'solicitude',
	#       sender: current_user,
	#       content: "#{current_user.slug.capitalize} te ha invitado a ser juez en un encuentro.",
	#       url: club_duel_reservation_path(@club, @duel, @reservation),
	#       club_id: @club.id,
	#       category: 8,
	#       action: 10
	#     )
  #     redirect_to root_path # Redireccionar a la página principal o a donde sea necesario
  #   else

	# 	  flash[:alert] = "Ha habido un error al crear la reserva: " + @reservation.errors.full_messages.join(", ")
  #     redirect_back(fallback_location: request.referer)
  #   end
  # end


  def update
    if @reservation.update(reservation_params)
    	if @reservation.approved == true
      	@duel.update(referee_id: current_user.id, referee_name: current_user.slug, responsibility: true)
    	end
      flash[:notice] = "Done!"
    else
      flash[:notice] = @reservation.errors.full_messages
    end
    redirect_back(fallback_location: request.referer)
  end

  def show
  end


  def reply
  end





	private

		def set_club
  		@club = Club.friendly.find(params[:club_id])
		end

		def set_duel
			@duel = Duel.find(params[:duel_id])
		end

		def set_reservation
		  @reservation = @duel.reservations.find(params[:id])
		end

		def set_time
	  	start_time = @duel.start_date
			end_time = @duel.end_date

			duration = (end_time - start_time).to_i
			hours = duration / 3600
			minutes = (duration % 3600) / 60

			@formatted_duration = "#{hours}h #{minutes}min"
		end

    # def is_authorised
    # 	if user_signed_in?
		# 	  unless current_user.id == @duel.referee_id || current_user.id == @duel.user_id
	  #     	redirect_to root_path, alert: "No tienes suficiente autorización"
	  #   	end
	  #   else
	  #     redirect_to root_path, alert: "Debes ingresar primero."
	  #   end
    # end
		def is_authorised
		  if user_signed_in?
		    # Verificar si el usuario es el dueño del duelo o el árbitro de alguna reserva del duelo
		    referee_reservations = Reservation.where(duel_id: @duel.id)
		    is_referee = referee_reservations.exists?(referee_id: current_user.id)

		    unless current_user.id == @duel.referee_id || current_user.id == @duel.user_id || is_referee
		      redirect_to authenticated_root_path, alert: "You do not have sufficient authorization for this."
		    end
		  else
		    redirect_to unauthenticated_root_path, alert: "You must log in first."
		  end
		end

		def reservation_params
			params.require(:reservation).permit(:start_date, :end_date, :referee_id, :approved, :rejected, :club_id, :duel_id)
		end

end