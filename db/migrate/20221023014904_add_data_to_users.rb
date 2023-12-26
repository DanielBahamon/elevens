class AddDataToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :bio, :text
    add_column :users, :birthday, :datetime
    add_column :users, :owner, :boolean
    add_column :users, :partner, :boolean
    add_column :users, :active, :boolean
    add_column :users, :live, :boolean
    add_column :users, :praise, :integer
    add_column :users, :prestige, :integer
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :image, :string
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_index :users, :confirmation_token, unique: true
    add_column :users, :height, :integer
    add_column :users, :favfoot, :integer
    add_column :users, :favhand, :integer
    add_column :users, :weakfoot, :integer
    add_column :users, :weakhand, :integer
    add_column :users, :skills, :integer
    add_column :users, :rate, :integer
    add_column :users, :shot, :integer
    add_column :users, :pass, :integer
    add_column :users, :cross, :integer
    add_column :users, :dribbling, :integer
    add_column :users, :defense, :integer
    add_column :users, :physical, :integer
  end
end
