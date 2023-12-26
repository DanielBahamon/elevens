class AddChangesToLines < ActiveRecord::Migration[6.1]
  def up
    change_column :lines, :duel_id, :string
    change_column :lines, :club_id, :string
  end

  def down
    change_column :lines, :duel_id, :integer
    change_column :lines, :club_id, :integer
  end
end
