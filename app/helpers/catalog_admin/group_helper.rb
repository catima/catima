module CatalogAdmin::GroupHelper
  def show_token?(group)
    return false unless group.public?
    return false unless group.token?

    true
  end
end
