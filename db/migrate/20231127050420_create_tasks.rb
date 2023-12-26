class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :description
      t.datetime :deadline
      t.string :status
      t.string :user_id
      t.string :club_id
      t.string :duel_id
      t.string :url
      t.boolean :done, default: false

      t.timestamps
    end
  end
end
