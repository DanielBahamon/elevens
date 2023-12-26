class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	before_action :configure_devise_params, if: :devise_controller?

	def find_user_name
		if user_signed_in?
			return user.id
		end
	end


  def after_sign_in_path_for(resource)
    console_path
  end

	protected

		def configure_devise_params

			devise_parameter_sanitizer.permit(:sign_in) do |user_params|
			  user_params.permit(:email, :password, :remember_me)
			end
			
			devise_parameter_sanitizer.permit(:sign_up) do |user|
				user.permit(:firstname, :lastname, :email, :birthday, :password, :password_confirmation, :slug, :remember_me)
			end
			devise_parameter_sanitizer.permit(:account_update) do |user|
				user.permit(:firstname, :lastname, :email, :birthday, :password, :password_confirmation, :slug, 
		                	:bio, :owner, :partner, :active, :live, :photo, :image, :praise, :prestige, :height, 
		                	:favfoot, :favhand, :weakfoot, :weakhand, :skills, :rate, :shot, :pass, :cross, :dribbling,
		                	:defense, :physical, :sports, :position, :number, :coverpage, :avatar, :status, :latitude, :longitude)
			end
		end

end
