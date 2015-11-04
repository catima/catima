module NumberHelper
  # TODO: test
  def pluralize_with_delimiter(number, unit, options={})
    pluralize(number_with_delimiter(number, options), unit)
  end
end
