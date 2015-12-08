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
  def value_as_time_with_zone(item)
    value = raw_value(item)
    return nil if value.nil?
    Time.zone.at(value)
  end

  def value_as_components(item)
    time_with_zone = value_as_time_with_zone(item)
    return nil if time_with_zone.nil?
    time_with_zone.to_a[0...6].reverse
  end

  def assign_value_from_components(item, values)
    # Pad out datetime components with default values, as needed
    defaults = [Time.current.year, 1, 1, 0, 0, 0]
    values += defaults[values.length..-1]

    time_with_zone = Time.zone.local(*values)
    item.send("#{uuid}=", time_with_zone.to_i)
  end

  def decorate_item_class(klass)
    super
    field = self
    klass.send(:define_method, "#{uuid}_components") do
      field.value_as_components(self)
    end
    klass.send(:define_method, "#{uuid}_components=") do |values|
      field.assign_value_from_components(self, values)
    end
  end
end
