json.data do
  if params[:item_type_id].present? || @advanced_search_config.present?
    json.catalog_id params[:catalog_id]
    json.item_type_id params[:item_type_id]
    json.advanced_search do
      json.criteria do
        displayable_fields(@fields).each_with_index do |field, i|
          unless field.is_a?(Field::File) || field.is_a?(Field::Geometry)
            json.set! field.uuid do
              json.field_infos do
                json.id field.id
                json.type field.short_type_name
              end
              json.criterion_content do
                json.partial! partial: "api/v3/catalog/advanced_searches/fields/#{field.partial_name}_search_field", locals: {field: field}
              end
            end
          end
        end
      end
    end
    json.advanced_search_conf ''
  end
end
