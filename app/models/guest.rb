class Guest
  def catalog_role_at_least?(_catalog, _role_requirement)
    false
  end

  def authenticated?
    false
  end

  def system_admin?
    false
  end

  def admin_of_any_catalog?
    false
  end

  def editor_of_any_catalog?
    false
  end

  def admin_catalog_ids
    []
  end

  def editor_catalog_ids
    []
  end
end
