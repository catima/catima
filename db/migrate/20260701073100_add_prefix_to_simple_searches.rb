class AddPrefixToSimpleSearches < ActiveRecord::Migration[8.1]
  def change
    add_column :simple_searches, :prefix, :boolean, :default => true, :null => false
  end
end
