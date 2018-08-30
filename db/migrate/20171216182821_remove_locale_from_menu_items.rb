class RemoveLocaleFromMenuItems < ActiveRecord::Migration[4.2]
  def up
    rename_column :menu_items, :title, :title_old
    add_column :menu_items, :title, :jsonb
    rename_column :menu_items, :url, :url_old
    add_column :menu_items, :url, :jsonb
    remove_column :menu_items, :locale
  end

  def down
    add_column :menu_items, :locale, :string, default: 'fr'
    remove_column :menu_items, :url
    rename_column :menu_items, :url_old, :url
    remove_column :menu_items, :title
    rename_column :menu_items, :title_old, :title
  end
end
