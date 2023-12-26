class AddMakerToMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column :memberships, :maker_id, :string
  end
end
