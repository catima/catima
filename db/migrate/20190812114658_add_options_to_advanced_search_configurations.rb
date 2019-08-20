class AddOptionsToAdvancedSearchConfigurations < ActiveRecord::Migration[5.2]
  def up
    add_column :advanced_search_configurations, :options, :jsonb, :null => true
  end

  def down
    remove_column :advanced_search_configurations, :options
  end
end
