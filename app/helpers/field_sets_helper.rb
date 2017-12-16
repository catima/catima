# Handles ItemType/Category behavior with a common set of helpers to allow
# views to be reused for both models.
module FieldSetsHelper
  def edit_field_set_path(field_set)
    helper = "edit_catalog_admin_#{field_set.model_name.singular}_path"
    send(helper, field_set.catalog, I18n.locale, field_set)
  end

  def field_set_metadata(field_set)
    return if field_set.is_a?(Category)
    "(plural: “#{@field_set.name_plural}”, slug: “#{@field_set.slug}”)"
  end
end
