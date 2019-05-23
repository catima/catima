class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.string :name
      t.references :related_search, polymorphic: true, index: true
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
