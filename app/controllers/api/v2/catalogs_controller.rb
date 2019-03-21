class API::V2::CatalogsController < ApplicationController
  def show
    return not_available unless Catalog.valid?(params['catalog_slug'])

    catalog = Catalog.find_by(slug: params['catalog_slug'])
    return not_available unless catalog.visible

    render(json:
      {
        slug: catalog.slug,
        name: catalog.name,
        primary_language: catalog.primary_language,
        other_languages: catalog.other_languages,
        item_types: catalog.item_types.map do |it|
          {
            slug: it.slug,
            name: it.name,
            url: api_v2_items_url(slug: it.slug),
            item_count: it.items.count
          }
        end
      })
  end

  private

  def not_available
    render(json: { error: "Not available" })
  end
end
