class CreateLines < ActiveRecord::Migration[6.1]
  def change
    create_table :lines do |t|
      t.references :duel, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.string :user_id
      t.boolean :approve, default: false
      t.integer :status, default: 0
      t.integer :membership
      t.integer :number
      t.string :position

      t.timestamps
    end
  end
end
