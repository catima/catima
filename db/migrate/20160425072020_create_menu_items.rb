class CreateMenuItems < ActiveRecord::Migration[4.2]
  def change
    create_table :menu_items do |t|
      t.belongs_to :catalog, index: true, foreign_key: true
      t.string :slug
      t.string :title
      t.belongs_to :item_type, index: true, foreign_key: true
      t.belongs_to :page, index: true, foreign_key: true
      t.text :url
      t.integer :parent_id, index: true
      t.integer :rank

      t.timestamps null: false
    end

    add_foreign_key "menu_items", "menu_items", column: 'parent_id'
  end
end
