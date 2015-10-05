class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|
      t.string :name
      t.string :slug
      t.string :primary_language, :null => false, :default => "en"
      t.json :other_languages
      t.boolean :requires_review, :null => false, :default => false
      t.datetime :deactivated_at

      t.timestamps :null => false
    end

    add_index :catalogs, :slug, :unique => true
  end
end
