class GoalsController < ApplicationController
  before_action :set_user
  before_action :set_duel
  before_action :set_club
  before_action :authenticate_user! 


  # Acción para mostrar el formulario de creación de goles para un duelo específico
  def new
    @goal = @user.goals.build
  end

  # Acción para guardar los goles creados en el formulario
  def create
    @goal = @user.goals.build(goal_params)

    if @goal.save
      redirect_to @duel, notice: 'Saved!'
    else
      render :new
    end
  end

  def edit
    unless @goal.allow_edit_goal?(current_user)
      redirect_to root_path, alert: 'You do not have sufficient authorization for this.'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_duel
    @duel = Duel.find(params[:duel_id])
  end

  def set_club
    @club = Club.find(params[:club_id])
  end

  def goal_params
    params.require(:goal).permit(:user_id, :duel_id, :club_id, :championship, :time, :total)
  end

end
