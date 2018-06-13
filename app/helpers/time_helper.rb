module TimeHelper
  module FormBuilderExt
    # Customized version of built-in datetime_select with different defaults.
    # Additionally, a :format options (as described in Field::DateTime) can be
    # passed in to specify which components of the datetime to display.
    # E.g. :format => "Y" will display only the year drop-down.
    #
    def viim_datetime_select(method, options={}, html_options={})
      format = options.delete(:format)
      options = options.reverse_merge(datetime_options_from_format(format))
      options = options.reverse_merge(
        :include_blank => true,
        :start_year => Time.current.year + 1,
        :end_year => 1,
        :max_years_allowed => 3000
      )
      datetime_select(method, options, html_options)
    end

    def datetime_options_from_format(format)
      format ||= "YMDhms"
      {
        :include_seconds => format =~ /s/,
        :discard_minute  => format !~ /m/,
        :discard_hour    => format !~ /h/,
        :discard_day     => format !~ /D/,
        :discard_month   => format !~ /M/,
        :discard_year    => format !~ /Y/
      }
    end
  end
end

ActionView::Helpers::FormBuilder.include(TimeHelper::FormBuilderExt)
