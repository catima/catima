class SimpleSearchController < ApplicationController
  include CatalogSite

  def index
    @search = Search::Simple.new(catalog, params[:q])
  end
end
