class AddStyleFieldToCatalogs < ActiveRecord::Migration[4.2]
  def change
    add_column :catalogs, :style, :jsonb
  end
end
