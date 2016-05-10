class AddAdvertizeToCatalogs < ActiveRecord::Migration
  def change
    add_column :catalogs, :advertize, :boolean
  end
end
