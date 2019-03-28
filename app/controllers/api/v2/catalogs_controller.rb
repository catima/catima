class API::V2::CatalogsController < ApplicationController
  module Constraint
    def self.matches?(request)
      return false unless Catalog.valid?(request[:catalog_slug])

      # catalog = Catalog.find_by(slug: request[:catalog_slug])

      # Available only for public catalogs or internal requests
      # catalog.public? || request.host == "localhost"
      true
    end
  end

  def show
    catalog = Catalog.find_by(slug: params['catalog_slug'])

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
end
