class AddLogosToCatalogs < ActiveRecord::Migration
  def change
    add_column :catalogs, :logo_id, :string
    add_column :catalogs, :navlogo_id, :string
  end
end
