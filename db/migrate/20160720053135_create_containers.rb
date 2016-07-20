class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.belongs_to :page, index:true, foreign_key:true
      t.string :type
      t.string :slug, index:true
      t.integer :row_order
      t.jsonb :content

      t.timestamps null: false
    end
  end
end
