class CleaningUp < ActiveRecord::Migration[4.2]
  def change
    remove_column :fields, :name_old, :string
    remove_column :fields, :name_plural_old, :string

    remove_column :item_types, :name_old, :string
    remove_column :item_types, :name_plural_old, :string
  end
end
