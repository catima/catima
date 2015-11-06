class AddLocaleToAdvancedSearches < ActiveRecord::Migration
  def change
    add_column :advanced_searches,
               :locale, :string,
               :null => false,
               :default => "en"
  end
end
