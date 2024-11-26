class AddSeoIndexableToCatalogs < ActiveRecord::Migration[7.2]
  def change
    add_column :catalogs, :seo_indexable, :boolean, default: false, null: false
  end
end
