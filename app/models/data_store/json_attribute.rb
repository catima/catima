# Given an attribute name, this class facilitates defining an accessor of the
# same name but with the "_json" suffix. This accessor allows the original
# attribute to be read and written to using a raw JSON string, which will be
# automatically parsed. If the JSON string that is provided is not valid JSON,
# a validation error will be added and the object will be marked invalid.
#
# Note that a "_json=" writer will be defined only if the underlying attribute
# also has a writer method defined.
#
# See DataStore::JsonAttributeTest for example usage.
#
class DataStore::JsonAttribute
  def self.define(item_class, name)
    attr = new(name)
    define_reader(item_class, name, attr)
    define_writer(item_class, name, attr)
    define_validator(item_class, name, attr)
  end

  def self.define_reader(item_class, name, attr)
    item_class.send(:define_method, "#{name}_json") do
      attr.get(self)
    end
  end
  private_class_method :define_reader

  def self.define_writer(item_class, name, attr)
    return unless item_class.public_method_defined?("#{name}=")

    item_class.send(:define_method, "#{name}_json=") do |json_string|
      attr.set(self, json_string)
    end
  end
  private_class_method :define_writer

  def self.define_validator(item_class, name, attr)
    validation_method = :"#{name}_has_valid_json"
    item_class.validate(validation_method)
    item_class.send(:define_method, validation_method) do
      attr.validate(self)
    end
  end
  private_class_method :define_validator

  def initialize(name)
    @name = name
  end

  def get(item)
    if item.instance_variable_defined?(json_string_variable)
      return item.instance_variable_get(json_string_variable)
    end

    data = item.public_send(name)
    generate_json(data)
  end

  # rubocop:disable Lint/HandleExceptions
  def set(item, json_string)
    item.instance_variable_set(json_string_variable, json_string)
    parsed_value = json_string.presence && JSON.parse(json_string)
    item.send("#{name}=", parsed_value)
  rescue JSON::ParserError
    # ignore
  end
  # rubocop:enable Lint/HandleExceptions

  def validate(item)
    json_string = item.instance_variable_get(json_string_variable)
    return if json_string.blank?

    begin
      JSON.parse(json_string)
    rescue StandardError
      item.errors.add(:"#{name}_json", "invalid JSON string")
    end
  end

  private

  attr_reader :name

  def json_string_variable
    :"@#{name}_json_string"
  end

  def generate_json(data)
    return nil if data.nil?
    JSON.pretty_generate(data)
  end
end
