class CreateFields < ActiveRecord::Migration[6.1]
  def change
    create_table :fields, id: false, force: true do |t|
      t.string :id, :limit => 36, :primary_key => true
      t.string :user_id
      t.boolean :approve, default: false
      t.integer :status, default: 0
      t.string :position
      t.string :name
      t.string :location
      t.string :country
      t.string :city
      t.string :neighborhood
      t.string :address
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :bathrooms, default: false
      t.boolean :parking, default: false
      t.boolean :wifi, default: false
      t.boolean :roof, default: false
      t.boolean :showers, default: false
      t.boolean :store, default: false
      t.boolean :waterfree, default: false
      t.boolean :videogames, default: false
      t.boolean :gym, default: false
      t.boolean :lockers, default: false
      t.boolean :snacks, default: false
      t.boolean :uniform, default: false
      t.boolean :private, default: false
      t.boolean :active, default: false
      t.integer :duels, default: 0
      t.integer :capacity
      t.integer :price, default: 0
      

      t.timestamps
    end
  end
end
