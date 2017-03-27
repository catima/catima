class API::V1::ItemTypeSerializer < ActiveModel::Serializer
  include API::V1::TranslationSerialization
  include Rails.application.routes.url_helpers

  has_many :fields, :serializer => API::V1::FieldSerializer

  attributes :id, :slug
  attribute(:name) { translation_hash(object.name_translations) }
  attribute(:name_plural) { translation_hash(object.name_plural_translations) }

  attribute(:_links) do
    {
      :items => api_v1_catalog_items_url(
        object.catalog.slug, :item_type => object.slug
      )
    }
  end
end
