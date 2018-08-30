class MakeFieldParentPolymorphic < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :fields, :item_types
    add_column :fields, :field_set_type, :string
    rename_column :fields, :item_type_id, :field_set_id
  end
end
