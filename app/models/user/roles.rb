module User::Roles
  def all_catalog_permissions
    # Contains all catalog permissions of the user and of all the
    # groups the user is member of.
    perms = catalog_permissions
    all_groups.each { |grp| perms += grp.catalog_permissions }
    resolve_catalog_permissions perms
  end

  def resolve_catalog_permissions(permissions)
    # For a collection of catalog permissions, remove duplicate permissions
    # and retain only the highest permission for each catalog.
    perm_per_catalog = {}
    permissions.each do |p|
      perm_per_catalog[p.catalog_id] = CatalogPermission.higher_permission(perm_per_catalog[p.catalog_id] || p, p)
    end
    perm_per_catalog.values
  end

  def catalog_role_at_least?(catalog, role_requirement, all=true)
    # Authenticated users are always considered at least "user" level.
    return true if role_requirement == "user"

    perm = (all == true ? all_catalog_permissions : catalog_permissions).to_a.find { |p| p.catalog_id == catalog.id }
    perm&.role_at_least?(role_requirement)
  end

  def catalog_role(catalog)
    perm = all_catalog_permissions.to_a.find { |p| p.catalog_id == catalog.id }
    perm ? perm.role : "user"
  end

  def catalog_visible_for_role?(catalog)
    return true if system_admin
    return catalog_role_at_least?(catalog, "editor") unless catalog.visible
    true
  end

  def can_list_item?(item)
    return false unless item.catalog.active?
    return false unless item.catalog.public_items.exists?(item.id)
    return false unless catalog_visible_for_role?(item.catalog)
    true
  end

  def admin_catalogs
    Catalog.where(:id => admin_catalog_ids)
  end

  def admin_catalog_ids
    role_catalog_ids("admin")
  end

  def reviewer_catalog_ids
    role_catalog_ids("reviewer")
  end

  def super_editor_catalog_ids
    role_catalog_ids("super-editor")
  end

  def editor_catalog_ids
    role_catalog_ids("editor")
  end

  def member_catalog_ids
    role_catalog_ids("member")
  end

  def role_catalog_ids(role)
    all_catalog_permissions.to_a.each_with_object([]) do |perm, admin|
      next unless perm.active?
      admin << perm.catalog_id if perm.role_at_least?(role)
    end
  end

  def admin_of_any_catalog?
    admin_catalog_ids.any?
  end

  def reviewer_of_any_catalog?
    reviewer_catalog_ids.any?
  end

  def super_editor_of_any_catalog?
    super_editor_catalog_ids.any?
  end

  def editor_of_any_catalog?
    editor_catalog_ids.any?
  end

  def member_of_any_catalog?
    member_catalog_ids.any?
  end
end
