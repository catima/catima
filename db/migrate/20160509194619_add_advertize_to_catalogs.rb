class AddAdvertizeToCatalogs < ActiveRecord::Migration[4.2]
  def change
    add_column :catalogs, :advertize, :boolean
  end
end
