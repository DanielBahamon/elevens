class MembershipsController < ApplicationController
	before_action :is_authorised, only: [:edit]
	before_action :set_club, except: [:index, :new, :create]
  before_action :set_membership, only: [:approve, :decline, :show]

	def show
	end

	def create
		@membership = current_user.memberships.build(club_id: params[:club_id])

	  respond_to do |format|
	    if @membership.save
				@memberships =  @club.memberships
				redirect_back(fallback_location: request.referer, notice: "Saved!")
	      format.js
	    else
			  flash[:error] = "Sorry. It is not possible."
			  redirect_back(fallback_location: request.referer)
	      format.js
	    end
	  end
	end

	def update
		if @membership.update(membership_params)
		  flash[:notice] = "Saved!"
		else
		  flash[:notice] = "Oops! Something went wrong."
		end
		redirect_back(fallback_location: request.referer)
	end

	# def destroy
	# 	@membership = @club.memberships.find(params[:id])
  #   @user = User.find(@membership.user_id)
  #   @club = Club.find(@membership.club_id)
	# 	@membership.destroy
  #   # charge(@membership.club, @membership)
	# 	flash[:notice] = "¡Membresia eliminada!"
	# 	redirect_back(fallback_location: request.referer)
	# end

	def destroy
	  @membership = Membership.find(params[:id])
	  @user = User.find(@membership.user_id)
	  @club = @membership.club
    Notification.create(recipient: @user, notification_type: 'rejected', sender: @club.user, content: "Your request for #{@club.slug} has been rejected.", url: club_path(@club.id), club_id: @club.id, category: 2, action: 3)
		@membership.destroy
	  if @membership.destroy
	    flash[:notice] = 'You have rejected the invitation!'
	  else
	    flash[:error] = 'The invitation could not be deleted.'
	  end
	  redirect_to console_path
	end

  def approve 
    @user = User.find(@membership.user_id)
    @membership.Approved!
    Notification.create(recipient: @user, notification_type: 'joined', sender: @club.user, content: "Your request for #{@club.slug} has been approved.", url: club_path(@club.id), club_id: @club.id, category: 2, action: 2)
    # charge(@membership.club, @membership)
		flash[:notice] = "Membership approved!"
		redirect_back(fallback_location: request.referer)
  end

  def decline
    @membership.Declined!
		flash[:alert] = "Membership denied!"

		redirect_back(fallback_location: request.referer)
  end



	private
    def set_club
        @club = Club.friendly.find(params[:club_id])
    end


    def set_membership
        @membership = Membership.find(params[:id])
    end

    def membership_params
      params.require(:membership).permit(:user_id, :club_id, :active, :slug, :firstname, :lastname, :status, :position, :number, :maker_id)
    end
end
