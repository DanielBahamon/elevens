class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def user
    # Obtener los clubs en los que el current_user es propietario o miembro aprobado
    @clubs = @user.clubs.includes(:memberships).where('memberships.status = 1 OR clubs.user_id = ?', @user.id)

    # Obtener los duelos relacionados con esos clubs para el mes actual
    @duels = Duel.where('(club_id IN (?) OR rival_id IN (?)) AND start_date >= ? AND start_date <= ?',
                        @clubs.pluck(:id), @clubs.pluck(:id),
                        Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
                 .where.not(rival_id: nil)
                 .order(:start_date)

    if params[:duel_id]
      @duel = Duel.find(params[:duel_id])
      start_date = Date.parse(params[:start_date])

      first_of_month = (start_date - 1.months).beginning_of_month
      end_of_month = (start_date + 1.months).end_of_month

      @events = @duel.club.events.where('(start_date BETWEEN ? AND ?)', first_of_month, end_of_month)
    else
      @duel = nil
      @events = []
    end
  end

  private

  def set_user
    @user = current_user
  end
end
