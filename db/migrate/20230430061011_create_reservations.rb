class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.references :user, type: :string, null: false, foreign_key: true
      t.references :duel, type: :string, null: false,  foreign_key: true
      t.references :club, type: :string, null: false,  foreign_key: true
      t.references :referee, type: :string, null: false,  foreign_key: true
      t.integer :position
      t.datetime :start_date
      t.datetime :end_date
      t.integer :price
      t.decimal :total, precision: 8, scale: 2
      t.boolean :approved, default: false
      t.boolean :rejected, default: false

      t.timestamps
    end
  end
end
