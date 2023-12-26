class RegistrationsController < Devise::RegistrationsController

  # prepend_before_action :check_captcha, only: [:create] # Change this to be any actions you want to protect.


  def create
    super do |resource|
      email_invitations = Invitation.where(email: resource.email, approved: false, rejected: false)

      if email_invitations.any?
        duel_id = email_invitations.first.duel_id
        club_id = email_invitations.first.club_id

        @duel = Duel.find_by(id: duel_id)
        @club = Club.find_by(id: club_id)
        @user = resource

        puts "Duel: #{@duel}"
        puts "club: #{@club}"


        email_invitations.each do |invitation|
          Notification.create(recipient: @user, notification_type: 'challenge', sender: @user, content: "#{@club.slug.capitalize} te ha desafiado a un duelo.", url: club_duel_path(@club, @duel), club_id: @club.id, category: 3, action: 10)
        end
      end
    end
  end


  private
    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new sign_up_params
        resource.validate # Look for any other validation errors besides reCAPTCHA
        set_minimum_password_length
        respond_with_navigational(resource) { render :new }
      end 
    end
    
  protected
    def update_resource(resource, params)
      if params[:password].present?
        resource.password = params[:password]
        resource.password_confirmation = params[:password_confirmation]
      end
      resource.update_without_password(params)
    end


end

