class AddSomechangesToDuels < ActiveRecord::Migration[6.1]
  def up
    change_column :duels, :status, :integer, default: 0
  end

  def down
    change_column :duels, :status, :string
  end
end
