class AddLatnadlongToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :latitude, :integer, precision: 10, scale: 6
    add_column :users, :longitude, :integer, precision: 10, scale: 6
  end
end
