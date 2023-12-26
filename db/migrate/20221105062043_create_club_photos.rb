class CreateClubPhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :club_photos do |t|
      t.references :club, null: false, foreign_key: true

      t.timestamps
    end
  end
end
