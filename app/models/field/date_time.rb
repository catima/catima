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
  include ::Field::HasJsonRepresentation

  FORMATS = %w(Y YM YMD YMDh YMDhm YMDhms).freeze

  store_accessor :options, :format
  after_initialize :set_default_format
  validates_inclusion_of :format, :in => FORMATS

  def type_name
    "Date time" + (persisted? ? " (#{format})" : "")
  end

  def custom_field_permitted_attributes
    %i(format)
  end


  private

  def set_default_format
    self.format ||= "YMD"
  end

end
