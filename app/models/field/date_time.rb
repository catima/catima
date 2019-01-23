# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_component        :string
#  display_in_list          :boolean          default(TRUE), not null
#  display_in_public_list   :boolean          default(TRUE), not null
#  editor_component         :string
#  field_set_id             :integer
#  field_set_type           :string
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  multiple                 :boolean          default(FALSE), not null
#  name_plural_translations :json
#  name_translations        :json
#  options                  :json
#  ordered                  :boolean          default(FALSE), not null
#  primary                  :boolean          default(FALSE), not null
#  related_item_type_id     :integer
#  required                 :boolean          default(TRUE), not null
#  restricted               :boolean          default(FALSE), not null
#  row_order                :integer
#  slug                     :string
#  type                     :string
#  unique                   :boolean          default(FALSE), not null
#  updated_at               :datetime         not null
#  uuid                     :string
#

class Field::DateTime < ::Field
  FORMATS = %w(Y M h YM MD hm YMD hms MDh YMDh MDhm YMDhm MDhms YMDhms).freeze

  store_accessor :options, :format
  after_initialize :set_default_format
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

  # Translates YMD.. hash into an array [Y, M, D, h, m, s] (or nil).
  def value_as_array(item)
    value = raw_value(item)
    return nil if value.nil?

    defaults = { "Y" => "", "M" => "", "D" => "", "h" => "", "m" => "", "s" => "" }
    components = defaults.map do |key, default_value|
      value[key] || default_value
    end
    components
  end

  # Translates YMD.. hash into an integer number (or nil).
  def value_as_int(item)
    components = value_as_array(item)
    return nil if components.nil?

    (0..(components.length - 1)).collect { |i| components[i].to_s.present? ? components[i] * 10**(10 - 2 * i) : 0 }.sum
  end

  # The form provides the datetime values as hash like
  # { 2 => 12, 1 => 2015, 3 => 31 }. This method transforms this value
  # to the internal storage representation.
  def assign_value_from_form(item, values)
    time_hash = form_submission_as_time_hash(values)
    item.public_send("#{uuid}=", time_hash)
  end

  # Rails submits the datetime from the UI as a hash of component values,
  # e.g. { 2 => 12, 1 => 2015, 3 => 31 }
  # Translate the submission into an appropriate hash,
  # e.g. { "Y" => 2015, "M" => 12, "D" => 31 }
  def form_submission_as_time_hash(values)
    values = coerce_to_array(values)
    return nil if values.empty?

    # Discard precision not required by format
    values = values[0...format.length]

    # Pad out datetime components with default values, as needed
    defaults = [Time.current.year, 1, 1, 0, 0, 0]
    values += defaults[values.length..-1]

    k = %w(Y M D h m s)[0...format.length]
    Hash[k.zip values]
  end

  # To facilitate form helpers, we need to create a virtual attribute that
  # handles translation to and from the actual stored value. This virtual
  # attribute gets the name "#{uuid}_time".
  # Another virtual attribute allows retrieving the time value as an integer
  # value for date comparisons. This attribute is "#{uuid}_int".
  def decorate_item_class(klass)
    super
    field = self
    klass.send(:define_method, "#{uuid}_time") do
      field.value_as_array(self)
    end
    klass.send(:define_method, "#{uuid}_time=") do |values|
      field.assign_value_from_form(self, values)
    end
    klass.send(:define_method, "#{uuid}_int") do
      field.value_as_int(self)
    end
  end

  def field_value_for_item(it)
    field_value(it, self)
  end

  def order_items_by
    "NULLIF(data->'#{uuid}'->>'Y', '')::int ASC,
    NULLIF(data->'#{uuid}'->>'M', '')::int ASC,
    NULLIF(data->'#{uuid}'->>'D', '')::int ASC,
    NULLIF(data->'#{uuid}'->>'h', '')::int ASC,
    NULLIF(data->'#{uuid}'->>'m', '')::int ASC,
    NULLIF(data->'#{uuid}'->>'s', '')::int ASC"
  end

  def search_conditions_as_hash(locale)
    [
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.exact", locale: locale), :key => "exact" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.after", locale: locale), :key => "after" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.before", locale: locale), :key => "before" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.between", locale: locale), :key => "between" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.outside", locale: locale), :key => "outside" }
    ]
  end

  def search_options_as_hash
    [
      { :format => format }
    ]
  end

  def sql_type
    "JSON"
  end

  private

  def transform_value(v)
    return nil if v.nil?
    return v if v.is_a?(Hash) && !v.key?("raw_value")

    v = { "raw_value" => v } if v.is_a?(Integer)
    v["raw_value"].nil? ? nil : v
  end

  def set_default_format
    self.format ||= "YMD"
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
