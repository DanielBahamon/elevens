class CreateReferees < ActiveRecord::Migration[6.1]
  def change
    create_table :referees, id: false, force: true do |t|
      t.string :id, limit: 36, primary_key: true, null: false 
      t.string :user_id
      t.string :firstname
      t.string :lastname
      t.string :slug
      t.integer :position
      t.integer :price, default: 0
      t.boolean :active, default: false
      t.boolean :status, default: false

      t.timestamps
    end
  end
end
