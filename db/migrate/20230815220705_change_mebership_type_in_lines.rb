class ChangeMebershipTypeInLines < ActiveRecord::Migration[6.1]
  def up
    change_column :lines, :membership, :string
  end

  def down
    change_column :lines, :membership, :integer
  end
end
