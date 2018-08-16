class AddLocaleToMenuItems < ActiveRecord::Migration[4.2]
  def change
    add_column :menu_items, :locale, :string, default: 'fr'
  end
end
