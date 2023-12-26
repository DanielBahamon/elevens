class AddChangeToMemberships < ActiveRecord::Migration[6.1]
  def up
    change_column :memberships, :user_id, :string
    change_column :memberships, :club_id, :string
  end

  def down
    change_column :memberships, :user_id, :integer
    change_column :memberships, :club_id, :integer
  end
end
