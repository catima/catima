module Field::HasJsonRepresentation

  def custom_item_permitted_attributes
    super + [:"#{uuid}_json"]
  end

  def value_as_json_string(item)
    existing_input = item.instance_variable_get("@#{uuid}_json_string")
    return existing_input unless existing_input.nil?

    hash = raw_value(item)
    hash = {raw_value: hash} unless hash.is_a?(Array) || hash.is_a?(Hash)
    hash && JSON.pretty_generate(hash)
  end

  def assign_value_from_json_string(item, json)
    item.instance_variable_set("@#{uuid}_json_string", json)
    item.public_send("#{uuid}=", nil) unless json != ''
    item.public_send("#{uuid}=", JSON.parse(json))
  rescue JSON::ParserError
    # ignore
  end

  def decorate_item_class(klass)
    super
    field = self
    klass.send(:define_method, "#{uuid}_json") do
      field.value_as_json_string(self)
    end
    klass.send(:define_method, "#{uuid}_json=") do |json|
      field.assign_value_from_json_string(self, json)
    end
  end

end
