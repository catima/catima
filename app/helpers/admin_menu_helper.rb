module AdminMenuHelper
  def admin_menu_visible?
    admin_menu_item_types.any? || viim_admin? || catalog_admin?
  end

  def admin_menu_item_types
    return [] unless catalog_scoped?
    return [] unless policy(catalog.items.new).show?

    catalog.item_types.sorted
  end

  def viim_admin?
    policy(Configuration).update?
  end

  def catalog_admin?
    return false unless catalog_scoped?

    policy(catalog).show?
  end
end
