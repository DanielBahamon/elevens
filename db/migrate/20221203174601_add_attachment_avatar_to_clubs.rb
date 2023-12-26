class AddAttachmentAvatarToClubs < ActiveRecord::Migration[6.1]
  def self.up
    change_table :clubs do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :clubs, :avatar
  end
end
