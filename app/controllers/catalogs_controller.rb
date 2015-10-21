class CatalogsController < ApplicationController
  def show
    find_active_catalog
    redirect_to_specify_locale
    remember_requested_locale
  end

  private

  # TODO: move most of this functionality to base class or mixin,
  # as it will be common to all catalog-scoped public-facing controllers.

  attr_reader :catalog
  helper_method :catalog

  def catalog_scoped?
    true
  end

  def redirect_to_specify_locale
    return if @catalog.valid_locale?(params[:locale])
    redirect_to(:locale => preferred_locale)
  end

  def preferred_locale
    locales = [current_user.try(:primary_language)]
    locales << @catalog.primary_language
    locales.find { |l| @catalog.valid_locale?(l) }
  end

  def remember_requested_locale
    return if params[:locale].nil?
    return unless current_user.authenticated?
    current_user.update_column(:primary_language, params[:locale])
    true
  end

  def find_active_catalog
    @catalog = Catalog.active.where(:slug => params[:catalog_slug]).first!
  end
end
