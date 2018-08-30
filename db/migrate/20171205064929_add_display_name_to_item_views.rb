class AddDisplayNameToItemViews < ActiveRecord::Migration[4.2]
  def change
    add_column :item_views, :default_for_display_name, :boolean, default: false
  end
end
