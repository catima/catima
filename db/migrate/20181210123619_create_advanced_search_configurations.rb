class CreateAdvancedSearchConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :advanced_search_configurations do |t|
      t.belongs_to :item_type, index: true, foreign_key: true
      t.belongs_to :catalog, index: true, foreign_key: true
      t.integer :creator_id
      t.jsonb :title_translations
      t.jsonb :description
      t.string :slug, index: true
      t.string :search_type, default: "default"
      t.jsonb :fields, default: {}

      t.timestamps null: false
    end
  end
end
