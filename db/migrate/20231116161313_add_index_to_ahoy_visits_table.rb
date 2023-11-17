class AddIndexToAhoyVisitsTable < ActiveRecord::Migration[7.0]
  def up
    add_index :ahoy_visits, [:visitor_token, :started_at]
  end
  def down
    remove_index :ahoy_visits, [:visitor_token, :started_at]
  end
end
