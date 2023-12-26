class AddAttachmentCoverpageToUsers < ActiveRecord::Migration[6.1]
  def self.up
    change_table :users do |t|
      t.attachment :coverpage
    end
  end

  def self.down
    remove_attachment :users, :coverpage
  end
end
