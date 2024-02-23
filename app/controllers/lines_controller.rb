class LinesController < ApplicationController
  before_action :set_club
  before_action :set_duel
  before_action :set_line, except: [:index, :new, :create, :joinlines]
  before_action :set_membership, except: [:index, :new, :create]
  before_action :is_authorised, only: [:edit]
  before_action :set_breadcrumbs, except: [:index, :new, :create]
  before_action :authenticate_user!

  def index
    @all = @duel.lines
    @no_approve = @all.where(approve: false)
    @approve = @all.where(approve: true)

    @memberships = @club.memberships
  end

  def joinlines
    @user = User.find(params[:id])
    @membership = Membership.where("memberships.user_id == '#{@user.id}'")[0]
    @duel = Duel.where("duels.id == '#{@duel.id}'")[0]
    @club = Club.find(params[:club_id])
    @line = @duel.lines.build(user_id: @user.id, club_id: params[:club_id], duel_id: @duel.id, approve: false, status: 1, membership: @membership.id)
    if @line.save
      Notification.create(recipient: @user, notification_type: 'callup', sender: current_user, content: "#{@club.club_name} has called you up for their next duel as #{params[:position]}.", url: club_duel_line_path(@club, @duel, @line), club_id: @club.id, category: 1, action: 1)
      redirect_back(fallback_location: request.referer, notice: "Called up!")
    else
      flash[:error] = @line.errors.full_messages
      redirect_back(fallback_location: request.referer, alert: "Oops! Something went wrong.")
    end
  end

  def create
    @liner = User.find(params[:line][:user_id])
    @membership = Membership.where("memberships.user_id == '#{@liner.id}'")[0]
    @duel = Duel.where("duels.id == '#{@duel.id}'")[0]
    @line = Line.new(line_params)
    if @line.save
      Notification.create(recipient: @liner, notification_type: 'callup', sender: current_user, content: "#{@club.club_name} te ha convocado a su proximo duelo como #{params[:line][:position]}.", url: club_duel_line_path(@club, @duel, @line), club_id: @club.id, category: 1, action: 1)
      redirect_back(fallback_location: request.referer, notice: "Called up!")
    else
      flash[:error] = "Sorry. It is not possible."
      redirect_back(fallback_location: request.referer, alert: "Oops! Something went wrong.")
    end
  end

  def update
    @memberships = @club.memberships
    if @line.update(line_params)
      flash[:notice] = "Saved!"
    else
      flash[:notice] = "Oops! Something went wrong."
    end
    redirect_back(fallback_location: request.referer)
  end

  def edit
    @memberships = @club.memberships
    if @line.update(line_params)
      flash[:notice] = "Saved!"
    else
      flash[:notice] = "Oops! Something went wrong."
    end
    redirect_back(fallback_location: request.referer)
  end
  
  def show
    add_breadcrumb 'Convocation', nil
    unless current_user.id == @line.user_id
      redirect_back(fallback_location: root_path, alert: "You do not have sufficient authorization for this.")
      return
    end
  end

  def join
    @guess = Club.where("clubs.id = '#{@duel.rival_id}'")[0]
    @local = Club.where("clubs.id = '#{@duel.club_id}'")[0] 

    @m = @duel.lines.build(duel_id: @line.duel, club_id: @guess.id, approve: true, membership: @membership.id, status: 1, user_id: member.id )
    
    respond_to do |format|
      if @m.save
        format.html { redirect_to(@club, :notice => "Great! You'll receive a response from the captain soon.") }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@club, :notice => "Oops! Something went wrong.") }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  def invoke
    @line.Invoke!
    # charge(@membership.club, @membership)
    flash[:notice] = "Called up!"
    redirect_back(fallback_location: request.referer)
  end

  def ejected
    @line.Ejected!
    flash[:alert] = "Denied!"
    redirect_back(fallback_location: request.referer)
  end

  def destroy
    @duel = Duel.find(params[:duel_id])
    @line = Line.find(params[:id])
    # Resto del código para eliminar la línea
    redirect_to club_path(@club)
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

    def set_breadcrumbs
      add_breadcrumb 'Console', console_path
      add_breadcrumb @club.club_name, club_path(@club)
      add_breadcrumb 'Duel', panel_club_duel_path
    end

    def set_membership
      @membership = Membership.where(club_id: @club.id)
    end

    def set_line
      @line = Line.find(params[:id])
    end
    
    def is_authorised
      redirect_to root_path, alert: "You do not have sufficient authorization for this."
    end

    def line_params
      params.require(:line).permit(:duel_id, :club_id, :user_id, :approve, :status, :position, :number, :reject, :url, :membership)
    end
end