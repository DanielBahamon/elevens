module ApplicationHelper
  include Rails.application.routes.url_helpers

  def avatar_url(user)
    return "https://dfqckra2c3mhq.cloudfront.net/assets/profile/avatar-placeholder.png" if user.nil?

    if user.provider == "facebook" && !user.avatar.attached?
      "https://graph.facebook.com/#{user.uid}/picture?type=large"
    elsif user.avatar.attached?
      url_for(user.avatar.variant(resize_to_limit: [150, 150]))
    elsif user.image
      user.image
    else
      gravatar_id = Digest::MD5::hexdigest(user.email).downcase
      "https://www.gravatar.com/avatar/#{gravatar_id}.jpg?d=identicon&s=150"
    end
  end

  
  def cloudfront_url_for(blob)
    return unless blob.attached?

    # Reemplaza 'my_distribution_id.cloudfront.net' con tu propio ID de distribución de CloudFront
    cloudfront_host = 'da2k6p53nda1n.cloudfront.net'
    url_for(blob).sub(URI.parse(url_for(blob)).host, cloudfront_host)
  end
end
