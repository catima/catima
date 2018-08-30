class CreateCatalogPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :catalog_permissions do |t|
      t.belongs_to :catalog, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
      t.string :role

      t.timestamps null: false
    end
  end
end
