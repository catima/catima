class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :description
      t.boolean :public
      t.references :owner, index: true, null: false, foreign_key: { to_table: :users }
      t.boolean :active

      t.timestamps
    end
  end
end
