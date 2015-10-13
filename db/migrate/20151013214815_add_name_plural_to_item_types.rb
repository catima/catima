class AddNamePluralToItemTypes < ActiveRecord::Migration
  def change
    add_column :item_types, :name_plural, :string
  end
end
