class AddBooleanToMemberships < ActiveRecord::Migration[6.1]
  def up
    change_column :memberships, :active, :boolean, using: 'active::boolean', default: false
  end

  def down
    change_column :memberships, :active, :string
  end
end
