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

class Field::Editor < ::Field
  store_accessor :options, :updater, :timestamps

  def custom_field_permitted_attributes
    %i(updater timestamps)
  end

  def original_editor(user_id)
    return nil if user_id.blank?

    ::User.find_by(id: user_id)
  end

  def last_editor(user_id)
    return nil if user_id.blank?

    ::User.find_by(id: user_id)
  end

  def field_value_for_item(item)
    user = ::User.find_by(id: item.updater_id)

    user.email if user.present?
  end

  def field_value_for_all_item(item)
    field_value_for_item(item)
  end

  def sql_type
    "INT"
  end
end
