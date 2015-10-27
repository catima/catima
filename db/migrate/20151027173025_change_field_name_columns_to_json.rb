class ChangeFieldNameColumnsToJson < ActiveRecord::Migration
  class Catalog < ActiveRecord::Base
  end

  class ItemType < ActiveRecord::Base
    belongs_to :catalog, :class_name => "ChangeFieldNameColumnsToJson::Catalog"
  end

  class Field < ActiveRecord::Base
    belongs_to :item_type,
               :class_name => "ChangeFieldNameColumnsToJson::ItemType"
  end

  def up
    rename_column :fields, :name, :name_old
    rename_column :fields, :name_plural, :name_plural_old
    add_column :fields, :name, :json
    add_column :fields, :name_plural, :json

    Field.find_each do |f|
      locale = f.item_type.catalog.primary_language
      f.update_columns(
        :name => { "name_#{locale}" => f.name_old },
        :name_plural => { "name_plural_#{locale}" => f.name_plural_old }
      )
    end
  end

  def down
    remove_column :fields, :name
    remove_column :fields, :name_plural
    rename_column :fields, :name_old, :name
    rename_column :fields, :name_plural_old, :name_plural
  end
end
