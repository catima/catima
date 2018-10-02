class AddRestrictedToCatalogs < ActiveRecord::Migration[5.2]
  def change
    add_column :catalogs, :restricted, :boolean, null: false, default: false
  end
end
