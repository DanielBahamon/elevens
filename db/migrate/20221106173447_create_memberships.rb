class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.string :active, :boolean, default: false
      t.string :slug 
      t.string :firstname
      t.string :lastname
      t.integer :status, default: 0
      t.string :position
      t.integer :number

      t.timestamps
    end
  end
end
