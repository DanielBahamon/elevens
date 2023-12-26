class CreateClubs < ActiveRecord::Migration[6.1]
  def change
    create_table :clubs, id: false, force: true do |t|
      t.string :id, limit: 36, primary_key: true, null: false 
      t.references :user, null: false, foreign_key: true
      t.string :club_name
      t.string :country
      t.string :city
      t.string :neighborhood
      t.string :members
      t.string :location
      t.string :status
      t.text :summary
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.boolean :private, default: false
      t.boolean :uniform, default: false
      t.boolean :training, default: false
      t.boolean :hydration, default: false
      t.boolean :owner, default: false
      t.boolean :active, default: false
      t.boolean :lockers, default: false
      t.boolean :snacks, default: false
      t.boolean :payroll, default: false
      t.boolean :bathrooms, default: false
      t.boolean :staff, default: false
      t.boolean :assistance, default: false
      t.boolean :roof, default: false
      t.boolean :parking, default: false
      t.boolean :wifi, default: false
      t.boolean :gym, default: false
      t.boolean :showers, default: false
      t.boolean :amenities, default: false
      t.boolean :payment, default: false
      t.boolean :transport, default: false
      t.boolean :lunch, default: false
      t.boolean :videogames, default: false
      t.boolean :air, default: false
      t.boolean :pools, default: false
      t.boolean :perdiem, default: false
      t.boolean :heating, default: false
      t.boolean :washers, default: false
      t.boolean :courses, default: false

      t.integer :price
      t.integer :duels, default: 0
      t.integer :champions, default: 0
      t.integer :wons, default: 0
      t.string :address
      t.string :captain
      t.string :sport
      t.string :sport_type

      t.timestamps
    end
  end
end
