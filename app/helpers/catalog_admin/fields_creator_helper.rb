module CatalogAdmin::FieldsCreatorHelper
  def field_updater_check_box(form)
    form.form_group(
      :updater,
      :help => t('updater_help')
    ) do
      form.check_box(:updater, :label => t('updater_enable'))
    end
  end

  def field_timestamps_check_box(form)
    form.form_group(
      :timestamps,
      :help => t('timestamps_help')
    ) do
      form.check_box(:timestamps, :label => t('timestamps_enable'))
    end
  end
end
