class AddLocaleToMenuItems < ActiveRecord::Migration
  def change
    add_column :menu_items, :locale, :string, default: 'fr'
  end
end
