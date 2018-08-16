class AddUuidToExistingFields < ActiveRecord::Migration[4.2]
  class Field < ActiveRecord::Base
  end

  def up
    Field.find_each do |field|
      field.update!(:uuid => SecureRandom.uuid)
    end
  end

  def down
    # pass
  end
end
