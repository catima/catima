class AddUuidToChoiceSet < ActiveRecord::Migration
  def up
    add_column :choice_sets, :uuid, :string
    add_index :choice_sets, :uuid, :unique => true

    ChoiceSet.find_each do |cs|
      cs.update!(:uuid => SecureRandom.uuid)
    end
  end

  def down
    remove_index :choice_sets, :uuid
    remove_column :choice_sets, :uuid
  end
end
