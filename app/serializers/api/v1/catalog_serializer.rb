class API::V1::CatalogSerializer < ActiveModel::Serializer
  attributes :id
  link(:self) { api_v1_catalog_url(object.slug) }
  link(:href) { catalog_home_url(object.slug) }
end
