class API::V1::CatalogsController < ActionController::Base
  module Constraint
    def self.matches?(request)
      return false unless Catalog.valid?(request[:catalog_slug])

      catalog = Catalog.find_by(slug: request[:catalog_slug])

      # Available only for public catalogs or internal requests
      catalog.public? || request.host == "localhost"
    end
  end

  def index
    render(:json => API::V1::PaginationSerializer.new(
      "catalogs", catalogs_scope, params
    ))
  end

  def show
    catalog = catalogs_scope.where(:slug => params[:slug]).first!
    render(:json => catalog)
  end

  private

  def catalogs_scope
    Catalog.active
  end
end
