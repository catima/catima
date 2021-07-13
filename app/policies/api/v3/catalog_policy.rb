class API::V3::CatalogPolicy < CatalogPolicy
  alias_method :index?, :user_is_catalog_admin?
end
