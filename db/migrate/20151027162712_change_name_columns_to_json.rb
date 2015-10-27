class ChangeNameColumnsToJson < ActiveRecord::Migration
  class Catalog < ActiveRecord::Base
  end

  class ItemType < ActiveRecord::Base
    belongs_to :catalog, :class_name => "ChangeNameColumnsToJson::Catalog"
  end

  def up
    rename_column :item_types, :name, :name_old
    rename_column :item_types, :name_plural, :name_plural_old
    add_column :item_types, :name, :json
    add_column :item_types, :name_plural, :json

    ItemType.find_each do |it|
      locale = it.catalog.primary_language
      it.update_columns(
        :name => { "name_#{locale}" => it.name_old },
        :name_plural => { "name_plural_#{locale}" => it.name_plural_old }
      )
    end
  end

  def down
    remove_column :item_types, :name
    remove_column :item_types, :name_plural
    rename_column :item_types, :name_old, :name
    rename_column :item_types, :name_plural_old, :name_plural
  end
end
