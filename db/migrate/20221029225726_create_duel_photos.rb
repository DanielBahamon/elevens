class CreateDuelPhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :duel_photos do |t|
      t.references :duel, null: false, foreign_key: true

      t.timestamps
    end
  end
end
