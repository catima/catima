class CreateSchemaFields < ActiveRecord::Migration
  def change
    create_table :schema_fields do |t|
      t.string :name
      t.text :definition
      t.text :description
      t.references :schema_element, index: true

      t.timestamps null: false
    end
  end
  add_foreign_key :schema_fields, :schema_elements
end