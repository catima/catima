class CreateConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :configurations do |t|
      t.string :root_mode, :null => false, :default => "listing"
      t.integer :default_catalog_id

      t.timestamps :null => false
    end

    add_foreign_key "configurations",
                    "catalogs",
                    :column => "default_catalog_id"
  end
end
