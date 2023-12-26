class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_club
  before_action :set_duel
  before_action :set_invitation, except: [:index, :new, :create]
  before_action :set_rival, except: [:index, :new, :create]
  before_action :set_referee, except: [:index, :new, :create]
  before_action :set_breadcrumbs, except: [:index, :new, :create]
  before_action :is_authorised, only: [:new, :create]
  
  def new
    @invitation = Invitation.new
  end

  def create
    token = SecureRandom.hex(16)

    @invitation = @duel.invitations.build(invitation_params)
    @invitation.token = token
    @invitation.club_id = @club.id
    @invitation.user_id = current_user.id
    @invitation.link = club_duel_path(@club.id, @duel.id)
    @invitation.link_register = "/registration/?token=#{token}"

    if @invitation.save
      redirect_back(fallback_location: request.referer, notice: "¡Invitación enviada!")
    else
      flash[:error] = @invitation.errors.full_messages
      redirect_back(fallback_location: request.referer, alert: "Ya haz sido invitado(a)")
    end
  end


	def index
		
	end

	def show
    add_breadcrumb 'Convocatoria', nil
    unless current_user.id == @line.user_id
      redirect_back(fallback_location: root_path, alert: "No tienes suficiente autorización")
      return
    end		
	end


	def update
    if @invitation.update(invitation_params)
      flash[:notice] = "¡Guardado!"
    else
      flash[:notice] = "Algo no anda bien"
    end
    redirect_back(fallback_location: request.referer)
	end

	def destroy
    @invitation = Invitation.find(params[:id])
    redirect_to club_duel_path(@club, @duel)
	end

	def edit
    if @invitation.update(invitation_params)
      flash[:notice] = "¡Guardado!"
    else
      flash[:notice] = "Algo no anda bien"
    end
    redirect_back(fallback_location: request.referer)
	end



  def send_invitation
    token = SecureRandom.hex(16)

    cel = params[:cel]
    email = params[:email]

    Invitation.create(token: token, email: email, duel_id: @duel.id, 
                      club_id: @club.id, user_id: current_user.id, 
                      referee_id: @referee.id, text: "Tienes una nueva invitación pendiente a un duelo", 
                      title: "Invitación", link: club_duel_path(@club.id, @duel.id))

    invitation_link = "#{new_registration_path}?token=#{token}"

    if @invitation.save
      redirect_back(fallback_location: request.referer, notice: "Convocado!")
    else
      flash[:error] = @invitation.errors.full_messages
      redirect_back(fallback_location: request.referer, alert: "Error")
    end
  end



  private

    def set_invitation
        @invitation = Invitation.find(params[:id])
    end

    def set_duel
        @duel = Duel.find(params[:duel_id])
    end
    
    def set_rival
        @rival = User.find(params.require(:rival_id))
    end
    
    def set_club
        @club = Club.friendly.find(params.require(:club_id))
    end

    def set_referee
      @referee = User.find(params.require(:referee_id))
    end

    def is_authorised
      redirect_to root_path, alert: "No tienes suficiente autorización" unless current_user.id == @club.user_id || current_user.id == @rival.user_id
    end

    def set_breadcrumbs
      add_breadcrumb 'Consola', console_path
      add_breadcrumb @club.club_name, club_path(@club)
      add_breadcrumb 'Duelo', conditions_club_duel_path
    end

    def invitation_params
      params.require(:invitation).permit(:token, :user_id, :club_id, :duel_id, :rival_id, :referee_id, :link_register, :cel, :email, :text, :title, :approved, :rejected, :link)
    end
end