class CatalogsController < ApplicationController
  def show
    find_active_catalog
    apply_default_locale
  end

  private

  def apply_default_locale
    return if @catalog.valid_locale?(params[:locale])
    redirect_to(:locale => @catalog.primary_language)
  end

  def find_active_catalog
    @catalog = Catalog.active.where(:slug => params[:catalog_slug]).first!
  end
end
