class AddChangeToClubs < ActiveRecord::Migration[6.1]
  def up
    change_column :clubs, :user_id, :string
  end

  def down
    change_column :clubs, :user_id, :integer
  end
end
