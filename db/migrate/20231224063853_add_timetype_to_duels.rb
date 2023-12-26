class AddTimetypeToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :time_type, :integer
  end
end
