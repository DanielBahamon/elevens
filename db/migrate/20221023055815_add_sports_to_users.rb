class AddSportsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :sports, :string
  end
end
