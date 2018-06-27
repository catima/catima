class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.references :user, index: true, foreign_key: true
      t.references :catalog, index: true, foreign_key: true
      t.string :category
      t.string :status

      t.timestamps null: false
    end
  end
end
