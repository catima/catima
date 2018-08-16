class CreateFavorites < ActiveRecord::Migration[4.2]
  def change
    create_table :favorites do |t|
      t.references :user, index: true, foreign_key: true
      t.references :item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
