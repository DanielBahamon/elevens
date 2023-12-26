class AddChangesToNotifications < ActiveRecord::Migration[6.1]
  def up
    change_column :notifications, :recipient_id, :string
    change_column :notifications, :sender_id, :string
  end

  def down
    change_column :notifications, :recipient_id, :integer
    change_column :notifications, :sender_id, :integer
  end
end
