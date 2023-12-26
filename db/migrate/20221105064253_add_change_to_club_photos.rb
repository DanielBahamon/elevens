class AddChangeToClubPhotos < ActiveRecord::Migration[6.1]
  def up
    change_column :club_photos, :club_id, :string
  end

  def down
    change_column :club_photos, :club_id, :integer
  end
end
