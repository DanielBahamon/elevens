class CreateCalendars < ActiveRecord::Migration[6.1]
  def change
    create_table :calendars do |t|
      t.datetime :day
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :price, precision: 8, scale: 2
      t.integer :status
      t.string :user_id
      t.string :club_id
      t.string :duel_id
      t.string :referee_id
      t.integer :type_reservation

      t.timestamps
    end
  end
end
