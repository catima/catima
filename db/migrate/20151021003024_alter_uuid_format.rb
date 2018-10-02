class AlterUuidFormat < ActiveRecord::Migration[4.2]
  class Field < ActiveRecord::Base
  end

  class Item < ActiveRecord::Base
  end

  def up
    Field.find_each do |field|
      field.uuid = "_#{field.uuid.tr('-', '_')}"
      field.save!
    end

    Item.find_each do |item|
      next if item.data.nil?

      item.data = item.data.transform_keys do |uuid|
        "_#{uuid.tr('-', '_')}"
      end
      item.save!
    end
  end

  def down
    Field.find_each do |field|
      field.uuid = field.uuid.sub(/^_/, "").tr("_", "-")
      field.save!
    end

    Item.find_each do |item|
      next if item.data.nil?

      item.data = item.data.transform_keys do |uuid|
        uuid.sub(/^_/, "").tr("_", "-")
      end
      item.save!
    end
  end
end
