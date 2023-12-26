class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = current_user.tasks.order(created_at: :desc)
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: 'Tarea creada exitosamente.'
    else
      flash.now[:error] = 'Hubo un error al crear la tarea.'
      render :new
    end
  end
  
  def create_duel_task
    @task = Task.new(task_params)
    @task.user = current_user
    @task.club_id = params[:club_id]
    @task.duel_id = params[:duel_id]
  
    if @task.save
      redirect_to club_path(@task.club_id), notice: 'Tarea creada exitosamente.'
    else
      flash.now[:error] = 'Hubo un error al crear la tarea.'
      render :new
    end
  end

  
  private

  def task_params
    params.require(:task).permit(:description, :deadline, :status, :done, :start_date, :end_date) # Ajusta según los campos que necesites
  end
end