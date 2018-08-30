class AddLocaleToAdvancedSearches < ActiveRecord::Migration[4.2]
  def change
    add_column :advanced_searches,
               :locale, :string,
               :null => false,
               :default => "en"
  end
end
