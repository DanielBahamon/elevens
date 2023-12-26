class AddAttachmentImageToDuelPhotos < ActiveRecord::Migration[6.1]
  def self.up
    change_table :duel_photos do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :duel_photos, :image
  end
end
