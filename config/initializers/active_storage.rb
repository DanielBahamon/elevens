# config/initializers/active_storage.rb

Rails.application.reloader.to_prepare do
  ActiveStorage::Blob.class_eval do
    def url(expires_in: 5.minutes, disposition: "inline", filename: nil, content_type: nil)
      if service_name.to_s == "amazon"
        "https://da2k6p53nda1n.cloudfront.net/#{key}"
      else
        service.url(key, expires_in: expires_in, filename: filename, content_type: content_type, disposition: disposition)
      end
    end
  end
end
