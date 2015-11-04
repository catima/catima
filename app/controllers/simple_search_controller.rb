class SimpleSearchController < ApplicationController
  include ControlsCatalog

  def index
    @search = Search::Simple.new(
      :catalog => catalog,
      :query => params[:q],
      :page => params[:page]
    )
  end
end
