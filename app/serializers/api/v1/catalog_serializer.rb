class API::V1::CatalogSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  has_many :item_types, :serializer => API::V1::ItemTypeSerializer

  attributes :name, :primary_language, :slug
  attribute(:advertize) { object.advertize? }
  attribute(:other_languages) { object.other_languages || [] }

  attribute(:_links) do
    {
      :self => api_v1_catalog_url(object.slug),
      :items => api_v1_catalog_items_url(object.slug),
      :html => send("catalog_#{object.slug}_url")
    }
  end
end
