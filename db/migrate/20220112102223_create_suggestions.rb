class CreateSuggestions < ActiveRecord::Migration[6.1]
  def change
    create_table :suggestions do |t|
      t.text :content
      t.belongs_to :catalog, index: true, null: false,  foreign_key: true
      t.belongs_to :item, index: true, null: false,  foreign_key: true
      t.belongs_to :item_type, index: true, null: false,  foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
      t.datetime :processed_at

      t.timestamps
    end
  end
end
