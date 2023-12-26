require_relative "boot"

require "rails/all"

require 'breadcrumbs_on_rails'

Bundler.require(*Rails.groups)

module Elevens
  class Application < Rails::Application
    config.load_defaults 6.1

    # Configurar zona horaria predeterminada para la aplicación (por ejemplo, Bogotá)
    config.time_zone = "Bogota"

    # Configurar zona horaria predeterminada de la base de datos (por ejemplo, :local)
    config.active_record.default_timezone = :utc

    # Configurar zonas horarias adicionales para diferentes países
    config.timezones = {
      "Bogota" => "America/Bogota",
      "Londres" => "Europe/London",
      "Tokio" => "Asia/Tokyo",
      # Agrega más zonas horarias según tus necesidades
    }

    # Resto del código...

    # Este método te permitirá cambiar la zona horaria en función de la ubicación del usuario o alguna otra lógica
    def set_timezone
      if request.location.present?
        # Si se pudo obtener la ubicación del usuario, utiliza el gem 'timezone' para obtener la zona horaria correspondiente
        latitude = request.location.latitude
        longitude = request.location.longitude
        timezone = Timezone.lookup(latitude, longitude)
        Time.zone = timezone.name if timezone.present?
      end

      # Si no se pudo obtener la ubicación del usuario o no se encontró la zona horaria adecuada, se usará "Bogota" como predeterminada
      Time.zone ||= "Bogota"
    end

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    

    Geocoder.configure(
      lookup: :google,
      api_key: ENV['AIzaSyAz-J87QC1qvkimHdAE55GcV4Qpt8STDzc'],
      use_https: true,
      units: :km
    )
  end
end
