class DuelPhotosController < ApplicationController
	def create
		@duel = Duel.find(params[:duel_id])
		
		if params[:images]
			params[:images].each do |img|
				@duel.duel_photos.create(image: img)
			end
			@duel_photos =  @duel.duel_photos
			redirect_back(fallback_location: request.referer, notice: "Saved!")
		end
	end

	def destroy

		@duel_photo = DuelPhoto.find(params[:id])
		duel = @duel_photo.duel

		@duel_photo.destroy
		# @duel_photos = DuelPhoto.where(duel_id: duel.id)
		@duel_photos = duel.duel_photos 

		respond_to do |format|
			format.js
			format.html { redirect_back(fallback_location: request.referer, notice: "Deleted.") }
		end
	end
end
 