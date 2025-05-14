class AddDescriptionToCatalogs < ActiveRecord::Migration[7.2]
  def change
    add_column :catalogs, :description, :jsonb, null: true
  end
end
