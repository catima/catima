class SimpleSearchController < ApplicationController
  include ControlsCatalog

  def index
    @search = Search::Simple.new(catalog, params[:q])
  end
end
