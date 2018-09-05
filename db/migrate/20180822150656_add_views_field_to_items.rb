class AddViewsFieldToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :views, :jsonb
  end
end
