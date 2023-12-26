module ApplicationHelper
	def avatar_url(user)
		if user == nil
		      "https://dfqckra2c3mhq.cloudfront.net/assets/profile/avatar-placeholder.png"
		elsif user.provider != "facebook" && !user.avatar?
		    if user.image
		      user.image
		    else
		      gravatar_id = Digest::MD5::hexdigest(user.email).downcase
		      "https://www.gravatar.com/avatar/#{gravatar_id}.jpg?d=identicon&s=150"
		    end
		elsif user.provider == "facebook" && !user.avatar?
		    "https://graph.facebook.com/#{user.uid}/picture?type=large"
		else
			user.avatar.url(:medium)
		end
	end
	
end
