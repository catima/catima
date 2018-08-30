class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.belongs_to :catalog, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
