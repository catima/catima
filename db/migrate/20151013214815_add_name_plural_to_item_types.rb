class AddNamePluralToItemTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :item_types, :name_plural, :string
  end
end
