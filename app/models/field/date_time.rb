# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_in_list          :boolean          default(TRUE), not null
#  field_set_id             :integer
#  field_set_type           :string
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  multiple                 :boolean          default(FALSE), not null
#  name_old                 :string
#  name_plural_old          :string
#  name_plural_translations :json
#  name_translations        :json
#  options                  :json
#  ordered                  :boolean          default(FALSE), not null
#  primary                  :boolean          default(FALSE), not null
#  related_item_type_id     :integer
#  required                 :boolean          default(TRUE), not null
#  row_order                :integer
#  slug                     :string
#  type                     :string
#  unique                   :boolean          default(FALSE), not null
#  updated_at               :datetime         not null
#  uuid                     :string
#

class Field::DateTime < ::Field
  # The Rails datetime form helpers submit components of the datetime as
  # individual attributes, like "#{uuid}_time(1i)", "#{uuid}_time(2i)", etc.
  # We need to explicitly permit them.
  def custom_item_permitted_attributes
    (1..6).map { |i| :"#{uuid}_time(#{i}i)" }
  end

  # The raw value in the JSON is stored as an integer. This translates it to
  # a ActiveSupport::TimeWithZone object (or nil).
  def value_as_time_with_zone(item)
    value = raw_value(item)
    return nil if value.nil?
    Time.zone.at(value)
  end

  # Rails submits the datetime from the UI as a hash of component values.
  # Translate the submission into an appropriate datetime value and store it.
  def assign_value_from_form(item, values)
    values = coerce_to_array(values)
    return item.public_send("#{uuid}=", nil) if values.empty?

    # Pad out datetime components with default values, as needed
    defaults = [Time.current.year, 1, 1, 0, 0, 0]
    values += defaults[values.length..-1]

    time_with_zone = Time.zone.local(*values)
    item.public_send("#{uuid}=", time_with_zone.to_i)
  end

  # To facilitate form helpers, we need to create a virtual attribute that
  # handles translation to and from the actual stored value. This virtual
  # attribute gets the name "#{uuid}_time".
  def decorate_item_class(klass)
    super
    field = self
    klass.send(:define_method, "#{uuid}_time") do
      field.value_as_time_with_zone(self)
    end
    klass.send(:define_method, "#{uuid}_time=") do |values|
      field.assign_value_from_form(self, values)
    end
  end

  private

  def coerce_to_array(values)
    return [] if values.nil?
    return values if values.is_a?(Array)
    # Rails datetime form helpers send data as e.g. { 1 => "2015", 2 => "12" }.
    values.keys.sort.each_with_object([]) do |key, array|
      array << values[key]
    end
  end
end
