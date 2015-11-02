require_dependency("field/file")

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
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  item_type_id             :integer
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

# An image is indistinguishable on the back end from a generic file, but it is
# a distinct field type so that we can display it differently in the UI.
class Field::Image < ::Field::File
  after_initialize :set_default_types

  private

  def set_default_types
    return if persisted? || types.present?
    self.types = "jpg, jpeg, png, gif"
  end
end
