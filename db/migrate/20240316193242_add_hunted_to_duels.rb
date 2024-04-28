class AddHuntedToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :hunted, :boolean, default: false
  end
end
