class AddAPIFiledsToCatalog < ActiveRecord::Migration[6.1]
  def change
    add_column :catalogs, :api_enabled, :boolean, default: false
    add_column :catalogs, :throttle_time_window, :integer, default: 1
    add_column :catalogs, :throttle_max_requests, :integer, default: 5
  end
end
