class API::V1::PageSerializer < ActiveModel::Serializer
  attributes :id, :slug, :title, :locale

  link(:self) do
    api_v1_catalog_page_url(object.id, :catalog_slug => object.catalog.slug)
  end

  link(:html) do
    page_url(
      object.slug,
      :catalog_slug => object.catalog.slug,
      :locale => object.locale
    )
  end
end
