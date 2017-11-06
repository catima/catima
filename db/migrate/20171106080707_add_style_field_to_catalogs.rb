class AddStyleFieldToCatalogs < ActiveRecord::Migration
  def change
    add_column :catalogs, :style, :jsonb
  end
end
