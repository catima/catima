class CreateItemViews < ActiveRecord::Migration
  def change
    create_table :item_views do |t|
      t.string :name
      t.belongs_to :item_type, index: true, foreign_key: true
      t.jsonb :template
      t.boolean :default_for_list_view
      t.boolean :default_for_item_view

      t.timestamps null: false
    end
  end
end
