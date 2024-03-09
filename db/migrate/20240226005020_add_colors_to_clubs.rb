class AddColorsToClubs < ActiveRecord::Migration[6.1]
  def change
    add_column :clubs, :main_color, :string, default: '#000000'
    add_column :clubs, :second_color, :string, default: '#FFFFFF'
    add_column :clubs, :front, :boolean, default: false
  end
end
