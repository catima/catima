class CreateChoices < ActiveRecord::Migration[4.2]
  def change
    create_table :choices do |t|
      t.belongs_to :choice_set, index: true, foreign_key: true
      t.text :long_name
      t.string :short_name

      t.timestamps null: false
    end
  end
end
