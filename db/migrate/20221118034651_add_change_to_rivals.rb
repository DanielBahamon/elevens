class AddChangeToRivals < ActiveRecord::Migration[6.1]
  def up
    change_column :rivals, :club_id, :string
    change_column :rivals, :duel_id, :string
    change_column :rivals, :user_id, :string
  end

  def down
    change_column :rivals, :club_id, :integer
    change_column :rivals, :duel_id, :integer
    change_column :rivals, :user_id, :integer
  end
end
