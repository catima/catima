class AddElementTypeToSchemaElements < ActiveRecord::Migration
  def change
    add_column :schema_elements, :element_type, :string
  end
end
