class AddSeoIndexableToItemType < ActiveRecord::Migration[7.2]
  def change
    add_column :item_types, :seo_indexable, :boolean, default: true, null: false
  end
end
