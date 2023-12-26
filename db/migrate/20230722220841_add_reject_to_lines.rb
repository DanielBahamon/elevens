class AddRejectToLines < ActiveRecord::Migration[6.1]
  def change
    add_column :lines, :reject, :boolean
  end
end
