class ConvertSelectedChoicesValuesToString < ActiveRecord::Migration[6.1]
  def change
    fields = Field.where(type: "Field::ComplexDatation")
    fields_uuid = Field.where(type: "Field::ComplexDatation").pluck(:uuid)
    item_types = ItemType.joins(:fields).where(fields: fields)

    total_count = item_types.count
    item_types.find_each.with_index(1) do |item_type, i|
      puts "Processing item_type #{i}/#{total_count}"

      item_type.items.find_each do |item|
        next unless (fields_uuids_in_data = item.data.keys & fields_uuid).any?
        data = item.data
        fields_uuids_in_data.each do |fields_uuid_in_data|
          next unless data[fields_uuid_in_data]['selected_choices'] && data[fields_uuid_in_data]['selected_choices']['value']

          data[fields_uuid_in_data]['selected_choices']['value'] = data[fields_uuid_in_data]['selected_choices']['value'].map(&:to_s)
        end

        item.update!(data: data)
      end
    end
  end
end
