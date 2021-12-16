json.id item.id
json.item_type_id item.item_type_id
json.created_at item.created_at
json.updated_at item.updated_at
unless (field = item.field_for_select).nil?
  json.primary_field do
    json.value item.data["#{field.uuid}"]
    json.field do
      json.partial! '/api/v3/catalog/shared/field', field: field
    end
    json.review_status item.review_status if item.catalog.requires_review
  end
end
if with_summary
  # bypass_displayable is used when no user is available, mainly with an api key
  json.item_summary strip_tags(item_summary(item, bypass_displayable: @authenticated_catalog.present?))
  json.thumbnail item_thumbnail(item, {style: :medium, no_html: true}) if item.try(:image?)
end
if with_field_values
  json.field_values do
    json.array! fields do |field|
      case field
      when Field::Compound
        json.value field.csv_value(item, @authenticated_catalog.present? ? false : @current_user) unless field.i18n?
        json.value do
          json.set! :"_translations", field.translation_values(item, @authenticated_catalog.present? ? false : @current_user)
        end
      when Field::Editor
        json.value Field::EditorPresenter.new(nil, item, field).value
      else
        json.value item.data["#{field.uuid}"]
      end
      json.field do
        json.partial! '/api/v3/catalog/shared/field', field: field
      end
      json.review_status item.review_status if item.catalog.requires_review
    end
  end
end
