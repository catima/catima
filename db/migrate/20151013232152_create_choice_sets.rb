class CreateChoiceSets < ActiveRecord::Migration[4.2]
  def change
    create_table :choice_sets do |t|
      t.belongs_to :catalog, index: true, foreign_key: true
      t.string :name
      t.datetime :deactivated_at

      t.timestamps null: false
    end
  end
end
