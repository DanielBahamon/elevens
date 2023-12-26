class CreateRivals < ActiveRecord::Migration[6.1]
  def change
    create_table :rivals do |t|
      t.references :club, null: false, foreign_key: true
      t.references :duel, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :rival_id
      t.string :status
      t.datetime :duel_date
      t.datetime :start_date
      t.datetime :end_date
      t.integer :duel_time
      t.integer :duel_score
      t.integer :duel_total
      t.boolean :approve, default: false

      t.timestamps
    end
  end
end
