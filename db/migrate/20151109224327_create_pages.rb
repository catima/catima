class CreatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :pages do |t|
      t.belongs_to :catalog, index: true, foreign_key: true
      t.integer :creator_id, :index => true
      t.integer :reviewer_id, :index => true
      t.string :slug
      t.text :title
      t.text :content
      t.string :locale
      t.string :status

      t.timestamps null: false
    end

    add_foreign_key "pages", "users", :column => "creator_id"
    add_foreign_key "pages", "users", :column => "reviewer_id"
  end
end
