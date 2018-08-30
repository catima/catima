class CreateItems < ActiveRecord::Migration[4.2]
  def change
    create_table :items do |t|
      t.belongs_to :catalog, :index => true, :foreign_key => true
      t.belongs_to :item_type, :index => true, :foreign_key => true
      t.json :data
      t.string :status
      t.integer :creator_id, :index => true
      t.integer :reviewer_id, :index => true

      t.timestamps null: false
    end

    add_foreign_key "items", "users", :column => "creator_id"
    add_foreign_key "items", "users", :column => "reviewer_id"
  end
end
