class CreateFields < ActiveRecord::Migration[4.2]
  def change
    create_table :fields do |t|
      t.belongs_to :item_type, :index => true, :foreign_key => true
      t.integer :category_item_type_id, :index => true
      t.integer :related_item_type_id, :index => true
      t.belongs_to :choice_set, :index => true, :foreign_key => true
      t.string :type
      t.string :name
      t.string :name_plural
      t.string :slug, :index => true
      t.text :comment

      t.integer :position, :null => false, :default => 0

      t.boolean :multiple, :null => false, :default => false
      t.boolean :ordered, :null => false, :default => false
      t.boolean :required, :null => false, :default => true
      t.boolean :i18n, :null => false, :default => false
      t.boolean :unique, :null => false, :default => false

      t.text :default_value
      t.json :options

      t.timestamps :null => false
    end

    add_foreign_key "fields", "item_types", :column => "category_item_type_id"
    add_foreign_key "fields", "item_types", :column => "related_item_type_id"
  end
end
