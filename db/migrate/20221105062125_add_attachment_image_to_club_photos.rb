class AddAttachmentImageToClubPhotos < ActiveRecord::Migration[6.1]
  def self.up
    change_table :club_photos do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :club_photos, :image
  end
end
