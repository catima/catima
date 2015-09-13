class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.string :view_type
      t.references :instance, index: true
      t.string :slug
      t.text :template
      t.text :elements

      t.timestamps null: false
    end
  end
end
