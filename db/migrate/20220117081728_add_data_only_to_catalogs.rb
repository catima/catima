class AddDataOnlyToCatalogs < ActiveRecord::Migration[6.1]
  def change
    add_column :catalogs, :data_only, :boolean, default: false
  end
end
