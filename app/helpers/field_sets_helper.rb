# Handles ItemType/Category behavior with a common set of helpers to allow
# views to be reused for both models.
module FieldSetsHelper
  def edit_field_set_path(field_set)
    helper = "edit_catalog_admin_#{field_set.model_name.singular}_path"
    send(helper, field_set.catalog, I18n.locale, field_set)
  end

  def field_set_metadata(field_set)
    return if field_set.is_a?(Category)

    "(#{I18n.t('plural').downcase}: “#{field_set.name_plural}”, #{I18n.t('slug').downcase}: “#{field_set.slug}”)"
  end

  # Return if the field_set is disabled for SEO indexing.
  # Return false if the catalog is not SEO indexable, even if the field_set is.
  # Return false for Cagegories.
  def seo_indexable_disabled?(field_set)
    return false if field_set.is_a?(Category)

    field_set.catalog.seo_indexable && !field_set.seo_indexable
  end
end
