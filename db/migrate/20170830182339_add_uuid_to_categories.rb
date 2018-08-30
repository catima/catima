class AddUuidToCategories < ActiveRecord::Migration[4.2]
  def up
    add_column :categories, :uuid, :string
    add_index :categories, :uuid, :unique => true

    Category.find_each do |c|
      c.update!(:uuid => SecureRandom.uuid)
    end
  end

  def down
    remove_index :categories, :uuid
    remove_column :categories, :uuid
  end
end
