class AddAdvancedSearchConfigurationToAdvancedSearches < ActiveRecord::Migration[8.0]
  def change
    add_reference :advanced_searches, :advanced_search_configuration, null: true, index: true, foreign_key: true
  end
end
