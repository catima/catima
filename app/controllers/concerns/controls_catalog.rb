# Behavior that is common to all catalog-scoped public controllers. Handles
# loading the catalog and setting the locale.
module ControlsCatalog
  extend ActiveSupport::Concern

  included do
    before_action :find_active_catalog
    before_action :redirect_to_valid_locale
    before_action :remember_requested_locale
    before_action :remember_current_page_for_login_logout
    before_action :visibility
    before_action :prepend_catalog_view_path
    helper_method :catalog
  end

  private

  attr_reader :catalog

  def visibility
    return if catalog_visible_to_user && catalog_unrestricted_to_user
    redirect_to(root_path, :alert => t("catalogs.not_visible", :catalog_name => catalog.name))
  end

  def catalog_visible_to_user
    return true if catalog.visible
    if current_user.authenticated?
      return true if current_user.system_admin
      return true if current_user.catalog_role_at_least?(catalog, "editor")
    end
    false
  end

  def catalog_unrestricted_to_user
    return true unless catalog.restricted
    if current_user.authenticated?
      return true if current_user.system_admin
      return true if current_user.catalog_role_at_least?(catalog, "member")
    end
    false
  end

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

  def remember_current_page_for_login_logout
    store_location_for(:user, request.path)
  end

  # This is the magic that allows views in the `catalogs` directory to
  # override those in the app. So for example, if the slug of the catalog is
  # "viatimages", overrides could be placed in `catalogs/viatimages/views`.
  def prepend_catalog_view_path
    prepend_view_path(catalog.customization_root.join("views"))
  end
end
