class AddSlugToFields < ActiveRecord::Migration[6.1]
  def change
    add_column :fields, :slug, :string
    add_index :fields, :slug, unique: true
  end
end
