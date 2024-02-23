class FieldsController < ApplicationController
  before_action :set_user
  before_action :set_field, except: [:index, :new, :create]
  before_action :authorize_creator, only: [ :budget, :description, :visuals, :location, :location, :destroy]

  def index
  end

  def show
  end

  def new
    @field = @user.fields.new
  end

  def create
    @field = @user.fields.build(field_params)
    
    # @field = Field.new(field_params)
    if @field.save
      respond_to do |format|
        format.html { redirect_to fields_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js { render :new }
      end
    end

  end

  def edit
  end

  
  def update
    if @field.update(field_params)
      flash[:notice] = "¡Guardado!"
    else
      flash[:notice] = "Algo no esta bien..."
    end
    redirect_back(fallback_location: request.referer)
  end

  private

    def set_field
      @field = Field.friendly.find(params[:id])
    end

    def set_user
      @user = User.friendly.find(params[:user_id])
    end

    def authorize_creator
      redirect_to root_path, alert: "No tienes suficiente autorización" unless current_user.id == @field.user_id
    end
  
    def field_params
      params.require(:field).permit(:approve, :status, :position, :name, :location, 
                                    :country, :city, :neighborhood, :address, :latitude, :longitude, :bathrooms, 
                                    :parking, :wifi, :roof, :showers, :store, :waterfree, :videogames, :gym, 
                                    :lockers, :snacks, :uniform, :private, :active, :duels, :capacity, 
                                    :price, :slug)
    end
end
 