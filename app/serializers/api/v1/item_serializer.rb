class API::V1::ItemSerializer < ActiveModel::Serializer
  include API::V1::TranslationSerialization
  include Rails.application.routes.url_helpers

  belongs_to :catalog, :serializer => API::V1::CatalogReferenceSerializer
  belongs_to :item_type

  attributes :id, :created_at, :updated_at

  attribute(:attributes) do
    object.applicable_fields.map do |field|
      {
        :type => ::Field::TYPES.to_a.rassoc(field.class.to_s).first,
        :label => translation_hash(field.name_translations),
        :i18n => field.i18n,
        :value => object.data[field.uuid]
      }
    end
  end

  attribute(:_links) do
    {
      :self => api_v1_catalog_item_url(object.catalog.slug, object.id),
      :html => item_url(
        object.catalog.slug,
        object.catalog.primary_language,
        object.item_type.slug,
        object
      )
    }
  end
end
