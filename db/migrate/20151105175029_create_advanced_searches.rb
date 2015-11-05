class CreateAdvancedSearches < ActiveRecord::Migration
  def change
    create_table :advanced_searches do |t|
      t.string :uuid
      t.belongs_to :item_type, index: true, foreign_key: true
      t.belongs_to :catalog, index: true, foreign_key: true
      t.integer :creator_id
      t.json :criteria

      t.timestamps null: false
    end
  end
end
