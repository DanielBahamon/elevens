class AddFormationToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :formation, :string
  end
end
