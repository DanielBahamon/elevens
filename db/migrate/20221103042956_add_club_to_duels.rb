class AddClubToDuels < ActiveRecord::Migration[6.1]
  def up
    change_table :duels do |t|
      t.references :club, index: true
    end
  end

  def down
    change_table :duels do |t|
      t.remove_references :club, index: true
    end
  end
end
