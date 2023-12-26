# Utiliza la versión de Ruby del Gemfile
FROM ruby:2.6.10

# Instala dependencias del sistema necesarias para las gemas
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Instala Bundler 2.4.13
RUN gem install bundler -v '2.4.13'

# Establece el directorio de trabajo en el contenedor
WORKDIR /app

# Copia los archivos Gemfile y Gemfile.lock al contenedor
COPY Gemfile Gemfile.lock ./

# Instala las gemas
RUN bundle install

# Copia el resto de los archivos de la aplicación al contenedor
COPY . .
