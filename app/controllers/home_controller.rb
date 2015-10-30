class HomeController < ApplicationController
  def index
    @catalogs = Catalog.active.sorted
  end
end
