class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :username_validator]
  before_action :set_user, except: [:index, :username_validator, :players]
  before_action :set_clubes
  before_action :is_authorised, only: [:update]

  def show
    @memberships = Membership.where(user_id: @user.id, status: 1)
    @followers = current_user.followers.order("created_at ASC")
    @following = current_user.following.order("created_at ASC")
    @clubs = Club.joins(:memberships).where(memberships: { id: @memberships.pluck(:id) })
    @myclubs = @user.clubs
    @duels = @user.duels
  end

  def index
  end

  def follow
    current_user.follow(@user)
    redirect_to @user
  end

  def unfollow
    current_user.unfollow(@user)
    redirect_to @user
  end

  def username_validator
    if params[:slug].size <= 2
      render json: { valid: false }
    elsif User.find_by_slug(params[:slug].downcase) || User.find_by_slug(params[:slug].upcase)
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
        params[:slug] == 'intel' || params[:slug] == 'amd' || params[:slug] == 'ryzen' || params[:slug] == 'gamer' ||
        params[:slug] == 'xxx' || params[:slug] == 'porno' || params[:slug] == 'sex' || params[:slug] == 'fuck' ||
        params[:slug] == 'policia' || params[:slug] == 'porn' || params[:slug] == 'cia' || params[:slug] == 'fbi' || params[:slug] == 'covid'
      render json: {valid:false}
    else
      render json: { valid: true }
    end
  end

  def calledup

    @memberships = Membership.where(user_id: @user.id, status: 1)
    @lines = Line.where(user_id: @user.id, approve: 1)
    @clubs = Club.joins(:memberships).where(memberships: { id: @memberships.pluck(:id) })
    @duels = Duel.where("((club_id IN (?) OR rival_id IN (?)) OR user_id = ?) AND active = ? AND start_date > ?", @clubs.ids, @clubs.ids, current_user.id, true, DateTime.now).order(start_date: :desc)
    @pasts = Duel.where("((club_id IN (?) OR rival_id IN (?)) OR user_id = ?) AND active = ? AND start_date < ?", @clubs.ids, @clubs.ids, current_user.id, true, DateTime.now).order(start_date: :desc)

    # @comings = Duel.where("(club_id = ? OR rival_id = ?) AND active = ? AND start_date > ?", @clubs.ids, @clubs.ids, true, DateTime.now).order(start_date: :desc)
    @soon  = Duel.where("club_id = ? AND active = ? AND start_date > ? AND rival_id IS NOT NULL", @clubs.ids.inspect, true, DateTime.now).order(:start_date).first
    @prev  = Duel.where("club_id = ? AND active = ? AND start_date > ? AND rival_id IS NULL", @clubs.ids.inspect, true, DateTime.now).order(:start_date).first
    if @prev
      time_remaining2 = @prev.start_date - DateTime.now
      if time_remaining2 <= 0
        @event_time2 = @prev.start_date.strftime("%H:%M %p - %B %d, %Y")
      elsif time_remaining2 <= 1.month
        if time_remaining2 >= 1.week
          weeks = (time_remaining2.to_i / 1.week.to_i).to_i
          @event_time2 = weeks > 1 ? "#{weeks} weeks" : "#{weeks} week"
        elsif time_remaining2 >= 1.day
          days = (time_remaining2.to_i / 1.day.to_i).to_i
          @event_time2 = days > 1 ? "#{days}d" : "#{days}d"
        elsif time_remaining2 >= 1.hour
          hours = (time_remaining2.to_i / 1.hour.to_i).to_i
          @event_time2 = hours > 1 ? "#{hours}h" : "#{hours}h"
        elsif time_remaining2 >= 1.minute
          minutes = (time_remaining2.to_i / 1.minute.to_i).to_i
          @event_time2 = minutes > 1 ? "#{minutes}min" : "#{minutes}min"
        else
          seconds = (time_remaining2.to_i).to_i
          @event_time2 = seconds > 1 ? "#{seconds}s" : "#{seconds}s"
        end
      else
        @event_time2 = @prev.start_date.strftime("%b %d, %Y %H:%M %p")
      end
    end
    if @soon
      time_remaining1 = @soon.start_date - DateTime.now

      if time_remaining1 <= 0
        @event_time1 = @soon.start_date.strftime("%H:%M %p - %B %d, %Y")
      elsif time_remaining1 <= 2.weeks
        days = time_remaining1.to_i / 1.day.to_i
        hours = (time_remaining1.to_i % 1.day.to_i) / 1.hour.to_i
        minutes = (time_remaining1.to_i % 1.hour.to_i) / 1.minute.to_i
        seconds = (time_remaining1.to_i % 1.minute.to_i)
        @event_time1 = "#{days}d #{hours}h #{minutes}m #{seconds}s"
      else
        @event_time1 = @soon.start_date.strftime("%b %d, %Y %H:%M %p")
      end
    end
  end
  
  def clubs
    @myclubs = current_user.clubs
    @memberships = current_user.memberships
    @lines = Line.where(user_id: current_user.id, approve: 1)
    @line_ids = @lines.pluck(:club_id)
    @club_ids = @memberships.pluck(:club_id)
    @playclubs = Club.where(id: @line_ids)
    @clubs = @myclubs + @playclubs

  end

  def mentions
    respond_to do |format|
      format.json { render :json => Mention.all(params[:q]) }
    end
  end

  def referee
    if current_user.referee && current_user.referee_confirmation
      @notifications = current_user.notifications.where(category: 8).order(created_at: :desc).limit(3)
      @notificated = User.where(id: @notifications.pluck(:recipient_id))
      @sender = User.where(id: @notifications.pluck(:sender_id))
      @duels = Duel.where(referee_id: current_user.id)
      @duel = Duel.where(referee_id: current_user.id).where('start_date >= ?', Date.today).order(:start_date).first
      @pasts = Duel.where("(referee_id IN (?)) AND active = ? AND start_date < ?", current_user.id, true, DateTime.now).order(start_date: :desc)
    else
      redirect_to root_path, alert: "You do not have sufficient authorization for this."
    end
  end

  def preview
    @memberships = Membership.where(user_id: @user.id, status: 1)
    @followers = current_user.followers.order("created_at ASC")
    @following = current_user.following.order("created_at ASC")
    @clubs = Club.joins(:memberships).where(memberships: { id: @memberships.pluck(:id) })
    @myclubs = @user.clubs
    @duels = @user.duels
  end

  private

    def set_user
      @user = User.friendly.find(params[:id])
    end

    def set_clubes
      @myclubs = current_user.clubs
      @mymemberships = current_user.memberships
      @mylines = Line.where(user_id: current_user.id, approve: 1)
      @myline_ids = @mylines.pluck(:club_id)
      @myclub_ids = @mymemberships.pluck(:club_id)
      @playclubs = Club.where(id: @myline_ids)
    end

    def user_params
      params.require(:user).permit(:phone_number, :pin, :latitude, :longitude)
    end
end
