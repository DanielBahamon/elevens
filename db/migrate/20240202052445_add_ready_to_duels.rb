class AddReadyToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :ready, :boolean, default: false
  end
end
