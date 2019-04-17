class CreateSimpleSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :simple_searches do |t|
      t.string :uuid
      t.belongs_to :catalog, index: true, foreign_key: true
      t.integer :creator_id
      t.string :query
      t.string :locale, :null => false, :default => "en"

      t.timestamps
    end
  end
end
