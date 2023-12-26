class CreateGoals < ActiveRecord::Migration[6.1]
  def change
    create_table :goals do |t|
      t.string :user_id
      t.string :duel_id
      t.string :club_id
      t.string :champion_id
      t.datetime :time
      t.integer :total

      t.timestamps
    end
  end
end
