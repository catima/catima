class API::V1::CatalogReferenceSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :slug
  attribute(:_links) { { :self => api_v1_catalog_url(object.slug) } }
end
