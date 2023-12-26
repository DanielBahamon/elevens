class CreateInvitations < ActiveRecord::Migration[6.1]
  def change
    create_table :invitations do |t|
      t.string :user_id
      t.string :club_id
      t.string :duel_id
      t.string :champion_id
      t.string :rival_id
      t.string :referee_id
      t.string :cel
      t.string :email
      t.string :text
      t.string :title
      t.string :link
      t.string :link_register
      t.string :token
      t.boolean :approved, default: false
      t.boolean :rejected, default: false

      t.timestamps
    end
  end
end
