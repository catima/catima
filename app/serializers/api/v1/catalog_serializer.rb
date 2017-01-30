class API::V1::CatalogSerializer < ActiveModel::Serializer
  attributes :id, :name, :primary_language, :other_languages, :slug
  attribute(:advertize) { object.advertize? }

  link(:self) { api_v1_catalog_url(object.slug) }
  link(:pages) { api_v1_catalog_pages_url(object.slug) }
  link(:html) { catalog_home_url(object.slug) }
end
