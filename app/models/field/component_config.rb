# Holds the logic used for determining what UI components are valid for a given
# field, including whether the field supports them at all. This is based on the
# "fields.json" configuration file.
#
# TODO: test
class Field::ComponentConfig
  def initialize(field)
    @field = field
  end

  def component_choice?(type)
    component_choices(type).many?
  end

  def component_choices(type)
    Array.wrap(json_config["#{type}_components"])
  end

  def components_are_valid
    validate_component(:editor)
    validate_component(:display)
  end

  def validate_component(type)
    value = field.send("#{type}_component")
    return if value.blank? || value.in?(component_choices(type))
    field.errors.add(:"#{type}_component", "is not a supported component")
  end

  def assign_default_components
    assign_default_component(:editor)
    assign_default_component(:display)
  end

  def assign_default_component(type)
    return if component_choice?(type)
    field.public_send("#{type}_component=", component_choices(type).first)
  end

  private

  delegate :catalog, :to => :field
  attr_reader :field

  def json_config
    config = JsonConfig.for_catalog(catalog).load("fields.json")
    config.fetch(field.class.to_s.split("::").last, {})
  end
end
