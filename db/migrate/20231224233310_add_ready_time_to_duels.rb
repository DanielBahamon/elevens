class AddReadyTimeToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :ready_time, :integer
  end
end
