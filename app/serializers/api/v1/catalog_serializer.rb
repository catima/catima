class API::V1::CatalogSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  has_many :item_types

  attributes :name, :primary_language, :slug
  attribute(:advertize) { object.advertize? }
  attribute(:other_languages) { object.other_languages || [] }

  attribute(:_links) do
    {
      :self => api_v1_catalog_url(object.slug),
      :html => catalog_home_url(object.slug)
    }
  end
end
