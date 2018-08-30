class CreateItemTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :item_types do |t|
      t.belongs_to :catalog, :index => true, :foreign_key => true
      t.string :label
      t.string :slug

      t.timestamps :null => false
    end

    add_index :item_types, :slug, :unique => true
  end
end
