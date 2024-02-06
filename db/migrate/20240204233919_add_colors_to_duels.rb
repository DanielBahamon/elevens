class AddColorsToDuels < ActiveRecord::Migration[6.1]
  def change
    add_column :duels, :color_local, :string
    add_column :duels, :color_rival, :string
  end
end
