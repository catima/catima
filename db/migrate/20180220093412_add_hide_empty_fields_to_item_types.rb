class AddHideEmptyFieldsToItemTypes < ActiveRecord::Migration
  def up
    add_column :item_types, :empty_fields, :boolean, :null => false, default: true
  end

  def down
    remove_column :item_types, :empty_fields
  end
end
