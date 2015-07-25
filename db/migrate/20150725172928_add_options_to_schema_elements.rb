class AddOptionsToSchemaElements < ActiveRecord::Migration
  def change
    add_column :schema_elements, :options, :text
  end
end
