module Field::AllowsMultipleValues
  def allows_multiple?
    true
  end

  def decorate_item_class(klass)
    super
    field = self
    klass.public_send(:before_validation) do
      field.strip_empty_values(self)
    end
  end

  def strip_empty_values(item)
    values = raw_value(item)
    return unless values.is_a?(Array)

    values.compact_blank!
  end
end
