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
end
