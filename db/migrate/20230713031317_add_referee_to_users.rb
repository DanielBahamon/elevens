class AddRefereeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :referee, :boolean, default: false
    add_column :users, :referee_confirmation, :boolean, default: false
  end
end
