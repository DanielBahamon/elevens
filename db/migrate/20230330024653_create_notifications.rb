class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :sender, polymorphic: true
      t.string :content
      t.string :notification_type
      t.string :notifiable_id
      t.string :url
      t.integer :category, default: 0
      t.integer :action, default: 0
      t.string :club_id
      t.string :user_id
      t.string :duel_id
      t.string :champion_id
      t.json :params
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :read_at
  end
end
