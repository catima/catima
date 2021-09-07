module CatalogAdmin::UsersHelper
  def setup_catalog_users_nav_link
    active = (params[:controller] == "catalog_admin/users") || (params[:controller] == "catalog_admin/groups")
    klass = "list-group-item list-group-item-action"
    klass << " active" if active

    link_to(t("users_and_groups"), catalog_admin_users_path, :class => klass)
  end

  # rubocop:disable Style/OptionalBooleanParameter
  def user_role_symbol(user, catalog, including_groups=false)
    return "Admin" if user.system_admin?

    catalog = catalog.nil? ? cat : catalog
    options = CatalogPermission::ROLE_OPTIONS.reverse
    options.delete("reviewer") unless catalog.requires_review?

    options.find do |each|
      user.catalog_role_at_least?(catalog, each, including_groups)
    end
  end

  def user_role(user, catalog, including_groups=false)
    user_role_symbol(user, catalog, including_groups).to_s.titleize
  end
  # rubocop:enable Style/OptionalBooleanParameter

  def user_role_id(user, catalog)
    return false unless user_role_symbol(user, catalog) != user_role_symbol(user, catalog, true)

    user.groups.detect { |g| g.role_for_catalog(catalog) == user_role_symbol(user, catalog, true) }.id
  end

  def render_catalog_admin_users_permission(form)
    render(
      :partial => "catalog_admin/users/nested_permission",
      :locals => {
        :f => form,
        :perm => sorted_permissions_for_edit(form.object, [catalog]).first
      })
  end

  def group_roles(group, catalog)
    options = CatalogPermission::ROLE_OPTIONS.dup
    options.delete('admin')
    options.delete('reviewer') unless catalog.requires_review?

    group_permission = group.role_for_catalog(catalog)
    options.map { |r| [r, r == group_permission] }
  end
end
