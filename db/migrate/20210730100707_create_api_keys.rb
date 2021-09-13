class CreateAPIKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :api_keys do |t|
      t.references :catalog, index: true, foreign_key: true
      t.string :label, null: false
      t.string :api_key, null: false, unique: true, index: true
      t.timestamps
    end
  end
end
