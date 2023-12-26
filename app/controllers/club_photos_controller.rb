class ClubPhotosController < ApplicationController
	def create
		@club = Club.friendly.find(params[:club_id])
		
		if params[:images]
			params[:images].each do |img|
				@club.club_photos.create(image: img)
			end
			@club_photos =  @club.club_photos
			redirect_back(fallback_location: request.referer, notice: "¡Guardado!")
		end
	end
	def destroy
		@club_photo = ClubPhoto.find(params[:id])
		club = @club_photo.club

		@club_photo.destroy
		@club_photos = ClubPhoto.where(club_id: club.id)

		respond_to :js
	end
end
 