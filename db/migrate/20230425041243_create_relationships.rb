class CreateRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :relationships do |t|
      t.string  :follower_id
      t.string  :followed_id
      t.integer :status, default: 0
      t.boolean :mute, default: false
      t.boolean :blocked, default: false
      t.boolean :active, default: true


      t.timestamps
    end

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
