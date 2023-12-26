class AddChangeToDuelPhotos < ActiveRecord::Migration[6.1]
  def up
    change_column :duel_photos, :duel_id, :string
  end

  def down
    change_column :duel_photos, :duel_id, :integer
  end
end
