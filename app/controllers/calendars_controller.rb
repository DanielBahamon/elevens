class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def host
    @tasks = current_user.tasks

    params[:start_date] ||= Date.today.to_s
    params[:end_date] ||= Date.today.to_s
    params[:task_id] ||= @tasks[0] ? @tasks[0].id : nil

    if params[:task_id]
      @task = Task.find(params[:task_id])
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      first_of_month = (start_date - 1.months).beginning_of_month
      end_of_month = (start_date + 1.months).beginning_of_month

      @tasks = @tasks.joins(:club).joins(:duel)
                      .select('tasks.*, clubs.*, duels.*' )
                      .where('tasks.start_date BETWEEN ? AND ?', first_of_month, end_of_month)
    else
      @task = nil
      @tasks = []
    end
    
  end

  private

  def set_user
    @user = current_user
  end
end
