module CatalogAdmin::ChoiceSetsHelper
  def setup_catalog_choices_nav_link
    active = (params[:controller] == "catalog_admin/choice_sets")
    klass = "list-group-item list-group-item-action"
    klass << " active" if active

    link_to(t("choices"), catalog_admin_choice_sets_path, :class => klass)
  end

  def choice_set_abbreviated_choices(set)
    choices = set.choices.limit(13).sorted
    names = choices.map(&:short_name)
    names[10..-1] = "and #{set.choices.count - 10} more" if names.size > 12
    names.join(", ")
  end

  def choice_category_select(form, options={})
    form.collection_select(
      :category_id,
      catalog.categories.sorted,
      :id,
      :name,
      options.reverse_merge(:include_blank => true)
      )
  end

  def choice_set_type_label(set)
    tag.span(t("catalog_admin.choice_sets.index.#{set.choice_set_type}"))
  end
end
