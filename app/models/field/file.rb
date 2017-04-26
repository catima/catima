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

class Field::File < ::Field
  include ::Field::AllowsMultipleValues

  store_accessor :options, :types

  validates_presence_of :types

  def custom_field_permitted_attributes
    %i(types)
  end

  def allowed_extensions
    types.to_s.split(/[,\s]+/).map do |token|
      token.strip[/^\.?(\S+)/, 1]
    end
  end

  def file_count(item)
    files = raw_value(item)
    return 0 if files.nil?
    files.is_a?(Array) ? files.count : 1
  end
end
