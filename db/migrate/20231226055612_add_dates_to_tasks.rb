class AddDatesToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :start_date, :datetime
    add_column :tasks, :end_date, :datetime
  end
end
