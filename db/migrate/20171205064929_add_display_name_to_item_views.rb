class AddDisplayNameToItemViews < ActiveRecord::Migration
  def change
    add_column :item_views, :default_for_display_name, :boolean, default: false
  end
end
