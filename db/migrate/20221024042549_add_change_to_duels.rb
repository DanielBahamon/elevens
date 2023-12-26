class AddChangeToDuels < ActiveRecord::Migration[6.1]
  def up
    change_column :duels, :user_id, :string
  end

  def down
    change_column :duels, :user_id, :integer
  end
end
