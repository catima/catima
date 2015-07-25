class CreateSchemaElements < ActiveRecord::Migration
  def change
    create_table :schema_elements do |t|
      t.string :name
      t.text :description
      t.references :instance, index: true

      t.timestamps null: false
    end
    add_foreign_key :schema_elements, :instances
  end
end
