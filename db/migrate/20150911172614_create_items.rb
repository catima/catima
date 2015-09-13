class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :schema_element, index: true
      t.text :data

      t.timestamps null: false
    end
    add_foreign_key :items, :schema_elements
  end
end
