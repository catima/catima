class API::V1::PageSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :slug, :title, :locale
  attribute(:_links) do
    {
      :self => api_v1_catalog_page_url(object.id, :catalog_slug => object.catalog.slug),
      :html => page_url(object.slug, :catalog_slug => object.catalog.slug, :locale => object.locale)
    }
  end
end
