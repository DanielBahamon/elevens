class CreateDuels < ActiveRecord::Migration[6.1]
  def change
    create_table :duels, id: false, force: true do |t|
      t.string :id, limit: 36, primary_key: true, null: false 
      t.string :rival_id
      t.references :user, null: false, foreign_key: true
      t.integer :duel_type
      t.string :address
      t.string :neighborhood
      t.string :city
      t.string :country
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :height
      t.integer :members
      t.integer :substitutes, default: 0
      t.string :duration
      t.decimal :price, precision: 8, scale: 2
      t.decimal :budget, precision: 8, scale: 2
      t.decimal :budget_place, precision: 8, scale: 2
      t.decimal :budget_equipment, precision: 8, scale: 2
      t.decimal :referee_price, precision: 8, scale: 2
      t.integer :duration_time
      t.integer :duration_goals
      t.integer :goals
      t.integer :duel_total
      t.string :place
      t.string :place_type
      t.string :referee_name
      t.string :referee_type
      t.integer :showerbaths
      t.integer :bathrooms
      t.string :audience_type
      t.string :name
      t.string :location
      t.string :listing
      t.text :summary
      t.string :status
      t.string :duel_class
      t.integer :sport
      t.string :sport_type
      t.boolean :active, default: false
      t.boolean :responsibility, default: false
      t.boolean :lockers, default: false
      t.boolean :private, default: false
      t.boolean :parking, default: false
      t.boolean :is_internet, default: false
      t.boolean :refreshment, default: false
      t.boolean :refreshment_summary, default: false
      t.boolean :audience, default: false
      t.boolean :referee, default: false
      t.boolean :sport_bib, default: false
      t.boolean :digital_counter, default: false
      t.boolean :streaming, default: false
      t.boolean :snacks, default: false
      t.datetime :start_date
      t.datetime :end_date
      t.integer :local_score, default: 0
      t.integer :rival_score, default: 0
      t.string :referee_id
      t.string :local_formation





      t.timestamps
    end
  end
end
