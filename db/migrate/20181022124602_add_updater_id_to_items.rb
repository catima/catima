class AddUpdaterIdToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :updater_id, :integer, index: true, foreign_key: true
  end
end
