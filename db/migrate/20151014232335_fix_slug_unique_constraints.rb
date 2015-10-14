class FixSlugUniqueConstraints < ActiveRecord::Migration
  def up
    remove_index :fields, :slug
    remove_index :item_types, :slug
    add_index :fields, [:item_type_id, :slug], :unique => true
    add_index :item_types, [:catalog_id, :slug], :unique => true
  end

  def down
    remove_index :fields, [:item_type_id, :slug]
    remove_index :item_types, [:catalog_id, :slug]
    add_index :fields, :slug
    add_index :item_types, :slug, :unique => true
  end
end
