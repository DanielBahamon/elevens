class ChangePositionTypeInUsers < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :position, :string
  end

  def down
    change_column :users, :position, :integer
  end
end
