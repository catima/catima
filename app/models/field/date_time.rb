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
#  editor_component         :string
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
  FORMATS = %w(Y YM YMD YMDh YMDhm YMDhms).freeze

  store_accessor :options, :format
  after_initialize :set_default_format
  after_initialize :set_default_editor_component
  validates_inclusion_of :format, :in => FORMATS

  def type_name
    "Date time" + (persisted? ? " (#{format})" : "")
  end

  def custom_field_permitted_attributes
    %i(format)
  end

  # The Rails datetime form helpers submit components of the datetime as
  # individual attributes, like "#{uuid}_time(1i)", "#{uuid}_time(2i)", etc.
  # We need to explicitly permit them.
  def custom_item_permitted_attributes
    (1..6).map { |i| :"#{uuid}_time(#{i}i)" }
  end

  # Translates YMD.. hash into ActiveSupport::TimeWithZone object (or nil).
  def value_as_datetime(item)
    value = raw_value(item)
    return nil if value.nil?
    defaults = { "Y" => 0, "M" => 1, "D" => 1, "h" => 0, "m" => 0, "s" => 0 }
    components = defaults.map do |key, default_value|
      value[key] || default_value
    end
    ::DateTime.civil_from_format(:local, *components)
  end

  def assign_value_from_form(item, values)
    time_with_zone = form_submission_as_time_with_zone(values)
    item.public_send("#{uuid}=", transform_value(time_with_zone&.to_i))
  end

  # Rails submits the datetime from the UI as a hash of component values.
  # Translate the submission into an appropriate datetime value.
  def form_submission_as_time_with_zone(values)
    values = coerce_to_array(values)
    return nil if values.empty?

    # Discard precision not required by format
    values = values[0...format.length]

    # Pad out datetime components with default values, as needed
    defaults = [Time.current.year, 1, 1, 0, 0, 0]
    values += defaults[values.length..-1]

    Time.zone.local(*values)
  end

  # To facilitate form helpers, we need to create a virtual attribute that
  # handles translation to and from the actual stored value. This virtual
  # attribute gets the name "#{uuid}_time".
  def decorate_item_class(klass)
    super
    field = self
    klass.send(:define_method, "#{uuid}_time") do
      field.value_as_datetime(self)
    end
    klass.send(:define_method, "#{uuid}_time=") do |values|
      field.assign_value_from_form(self, values)
    end
  end

  private

  def transform_value(v)
    return nil if v.nil?
    return v if v.is_a?(Hash) && !v.key?("raw_value")
    v = { "raw_value" => v } if v.is_a?(Integer)
    return nil if v["raw_value"].nil?
    dt = Time.zone.at(v["raw_value"])
    new_value = {}
    dt_complete = { Y: dt.year, M: dt.mon, D: dt.day, h: dt.hour, m: dt.min, s: dt.sec }
    format.split("").each do |c|
      new_value[c.to_s] = dt_complete[c.to_sym]
    end
    new_value
  end

  def set_default_format
    self.format ||= "YMD"
  end

  def set_default_editor_component
    return if persisted?
    self.editor_component ||= "DateTimeInput"
  end

  def coerce_to_array(values)
    return [] if values.nil?
    return values if values.is_a?(Array)
    # Rails datetime form helpers send data as e.g. { 1 => "2015", 2 => "12" }.
    values.keys.sort.each_with_object([]) do |key, array|
      array << values[key]
    end.compact
  end
end
