module Admin::ConfigurationsHelper
  ROOT_CHOICES = {
    :listing => "Catalog list (default)",
    :redirect => "Redirect to a catalog",
    :custom => "Custom"
  }.freeze

  def configuration_root_mode_choices(form)
    choices = ROOT_CHOICES.dup
    choices.delete(:redirect) if Catalog.active.none?

    form.collection_select(
      :root_mode,
      choices,
      :first,
      :second,
      :hide_label => true
    )
  end

  def configuration_redirect_choices(form)
    form.collection_select(
      :default_catalog_id,
      Catalog.active.sorted,
      :id,
      :name,
      :hide_label => true
    )
  end
end
