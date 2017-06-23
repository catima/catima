class API::V1::ItemSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :item_type_id, :created_at, :updated_at

  attribute(:attributes) do
    object.applicable_fields.each_with_object({}) do |field, attrs|
      attrs[field.uuid] = (object.data || {})[field.uuid]
    end
  end

  attribute(:_links) do
    {
      :self => api_v1_catalog_item_url(object.catalog.slug, object.id),
      :catalog => api_v1_catalog_url(object.catalog.slug),
      :html => item_url(
        object.catalog.slug,
        object.catalog.primary_language,
        object.item_type.slug,
        object
      )
    }
  end
end
