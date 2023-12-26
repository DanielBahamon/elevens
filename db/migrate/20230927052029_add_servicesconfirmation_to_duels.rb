class AddServicesconfirmationToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :serviceconfirmation, :boolean, default: false
    add_column :duels, :showformation, :boolean, default: false
  end
end
