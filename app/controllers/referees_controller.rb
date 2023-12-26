class RefereesController < ApplicationController
  before_action :set_referee, only: [:show, :edit, :update, :destroy]

  def index
    @referees = Referee.all
  end

  def show
  end

  def new
    @referee = Referee.new
  end

  def create
    @referee = Referee.new(id:current_user.id, user_id: current_user.id, firstname: current_user.firstname, lastname: current_user.lastname, slug: current_user.slug, position: 0)
    if @referee.save
      redirect_to @referee, notice: "¡Te has unido como árbitro!"
    else
      render :new
    end
  end
  
  # def create
  #   @referee = Referee.new(referee_params)
  #   @referee.user_id = current_user.id

  #   if @referee.save
  #     redirect_to @referee, notice: 'Referee was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  def edit
  end

  def feed
    
  end

  def update
    if @referee.update(referee_params)
      redirect_to @referee, notice: 'Referee was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @referee.destroy
    redirect_to referees_url, notice: 'Referee was successfully destroyed.'
  end

  private

  def set_referee
    @referee = Referee.find(params[:id])
  end

  def referee_params
    params.require(:referee).permit(:id, :firstname, :lastname, :slug, :position, :active, :status, :user_id, :price)
  end
end
