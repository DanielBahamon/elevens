class AddEditToUsers < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :position, :integer
  end

  def down
    change_column :users, :position, :string
  end
end
