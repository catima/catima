class AddUuidToItems < ActiveRecord::Migration[4.2]
  def up
    add_column :items, :uuid, :string
    add_index :items, :uuid, :unique => true

    Item.find_each do |i|
      i.update!(:uuid => SecureRandom.uuid)
    end
  end

  def down
    remove_index :items, :uuid
    remove_column :items, :uuid
  end
end
