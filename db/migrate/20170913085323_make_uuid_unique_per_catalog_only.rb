class MakeUuidUniquePerCatalogOnly < ActiveRecord::Migration[4.2]
  def up
    remove_index :choice_sets, :uuid
    add_index :choice_sets, [:uuid, :catalog_id], :unique => true

    remove_index :choices, :uuid
    add_index :choices, [:uuid, :choice_set_id], :unique => true

    remove_index :categories, :uuid
    add_index :categories, [:uuid, :catalog_id], :unique => true

    remove_index :items, :uuid
    add_index :items, [:uuid, :catalog_id], :unique => true
  end

  def down
    remove_index :choice_sets, [:uuid, :catalog_id]
    add_index :choice_sets, :uuid, :unique => true

    remove_index :choices, [:uuid, :choice_set_id]
    add_index :choices, :uuid, :unique => true

    remove_index :categories, [:uuid, :catalog_id]
    add_index :categories, :uuid, :unique => true

    remove_index :items, [:uuid, :catalog_id]
    add_index :items, :uuid, :unique => true
  end
end
