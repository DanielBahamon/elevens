class AddApproveservicesToClubs < ActiveRecord::Migration[6.1]
  def change
    add_column :clubs, :services_ready, :boolean, default: false
  end
end
