class CatalogAdmin::BaseController < ApplicationController
  layout "catalog_admin"
  before_action :authenticate_user!
  before_action :find_and_authorize_catalog
  after_action :verify_authorized

  private

  attr_reader :catalog
  helper_method :catalog

  def default_url_options
    {}
  end

  def catalog_scoped?
    true
  end

  def find_and_authorize_catalog
    @catalog = Catalog.where(:slug => params[:catalog_slug]).first!
    authorize(@catalog, :show?)
  end

  protected

  def track
    track_event("catalog_admin")
  end
end
