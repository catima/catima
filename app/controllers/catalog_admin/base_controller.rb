class CatalogAdmin::BaseController < ApplicationController
  layout "catalog_admin"
  before_action :authenticate_user!
  before_action :find_and_authorize_catalog

  private

  attr_reader :catalog
  helper_method :catalog

  def find_and_authorize_catalog
    @catalog = Catalog.where(:slug => params[:catalog_slug]).first!
    authorize(@catalog, :show?)
  end
end
