class RenameNameColumnsWithTranslationsSuffix < ActiveRecord::Migration
  def change
    rename_column :choices, :short_name, :short_name_translations
    rename_column :choices, :long_name, :long_name_translations
    rename_column :fields, :name, :name_translations
    rename_column :fields, :name_plural, :name_plural_translations
    rename_column :item_types, :name, :name_translations
    rename_column :item_types, :name_plural, :name_plural_translations
  end
end
