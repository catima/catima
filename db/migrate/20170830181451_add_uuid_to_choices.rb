class AddUuidToChoices < ActiveRecord::Migration
  def up
    add_column :choices, :uuid, :string
    add_index :choices, :uuid, :unique => true

    Choice.find_each do |ch|
      ch.update!(:uuid => SecureRandom.uuid)
    end
  end

  def down
    remove_index :choices, :uuid
    remove_column :choices, :uuid
  end
end
