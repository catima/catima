class API::V3::CatalogPolicy < CatalogPolicy
  include CatalogAdmin::CatalogsHelper

  def user_requirements_according_to_visibility?
    case catalog_access(catalog)
    when 1 then
      true
    when 2 then
      user_is_at_least_a_member?
    when 3 then
      user_is_at_least_an_editor?
    end
  end

  # Catalog
  alias_method :index?, :user_is_catalog_admin?
  alias_method :categories_index?, :user_is_catalog_admin?
  alias_method :choice_sets_index?, :user_is_catalog_admin?
  alias_method :groups_index?, :user_is_catalog_admin?
  alias_method :users_index?, :user_is_catalog_admin?
  alias_method :item_types_index?, :user_is_at_least_an_editor?

  # Category
  alias_method :category_fields_index?, :user_is_catalog_admin?

  #  ChoiceSet
  alias_method :choice_set_choices_index?, :user_is_catalog_admin?
  alias_method :choice_set_choice_show?, :user_is_catalog_admin?

  # ItemType
  alias_method :item_type_fields_index?, :user_is_catalog_admin?
  alias_method :item_type_items_index?, :user_requirements_according_to_visibility?
  alias_method :item_type_show?, :user_is_at_least_an_editor?
  alias_method :item_type_field_show?, :user_is_catalog_admin?
  alias_method :item_type_item_show?, :user_requirements_according_to_visibility?

  # SimpleSearch
  alias_method :simple_search_create?, :user_requirements_according_to_visibility?
  alias_method :simple_search_show?, :user_requirements_according_to_visibility?
end
