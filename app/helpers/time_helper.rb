module TimeHelper
  module FormBuilderExt
    # Customized version of built-in datetime_select with different defaults.
    def viim_datetime_select(method, options={}, html_options={})
      options = options.reverse_merge(
        :include_seconds => true,
        :include_blank => true,
        :start_year => Time.current.year + 1,
        :end_year => 1_900
      )
      datetime_select(method, options, html_options)
    end
  end
end

ActionView::Helpers::FormBuilder.include(TimeHelper::FormBuilderExt)
