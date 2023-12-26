class RelationshipsController < ApplicationController
  before_action :authenticate_mocker!
  before_action :find_user

  def index
  end

  def show
    @relationship = Relationship.find(params[:id])
    respond_to do |format|
      format.html { @relationship }
      format.js
    end
  end

  def create
    current_user.follow(@user)
    Notification.create(recipient: @user, notification_type: 'following', sender: current_user, content: "Haz empezado a seguir a #{@user.slug}", url: user_path(@user))
    # redirect_back fallback_location: root_path
    redirect_back(fallback_location: request.referer)
  end

  def destroy
    current_user.unfollow(@user)
    # redirect_back fallback_location: root_path
    redirect_back(fallback_location: request.referer)
  end

  private
  
    def find_user
      @user = User.find(params[:user_id])
    end

end
