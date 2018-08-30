class AddLogosToCatalogs < ActiveRecord::Migration[4.2]
  def change
    add_column :catalogs, :logo_id, :string
    add_column :catalogs, :navlogo_id, :string
  end
end
