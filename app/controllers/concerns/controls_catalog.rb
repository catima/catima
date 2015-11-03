# Behavior that is common to all catalog-scoped public controllers. Handles
# loading the catalog and setting the locale.
module ControlsCatalog
  extend ActiveSupport::Concern

  included do
    before_action :find_active_catalog
    before_action :redirect_to_valid_locale
    before_action :remember_requested_locale
    helper_method :catalog
  end

  private

  attr_reader :catalog

  def catalog_scoped?
    true
  end

  def find_active_catalog
    @catalog = Catalog.active.where(:slug => params[:catalog_slug]).first!
  end

  def redirect_to_valid_locale
    return if catalog.valid_locale?(params[:locale])
    redirect_to(:locale => preferred_locale)
  end

  def preferred_locale
    locales = [current_user.try(:primary_language)]
    locales << catalog.primary_language
    locales.find { |l| catalog.valid_locale?(l) }
  end

  def remember_requested_locale
    return if params[:locale].nil?
    return unless current_user.authenticated?
    return if current_user.primary_language == params[:locale]
    current_user.update_column(:primary_language, params[:locale])
    true
  end
end
