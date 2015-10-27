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

class Field::ChoiceSet < ::Field
  belongs_to :choice_set, :class_name => "::ChoiceSet"

  validates_presence_of :choice_set
  validates_inclusion_of :choice_set,
                         :in => :choice_set_choices,
                         :allow_nil => true

  def type_name
    "Choice set" + (choice_set ? " (#{choice_set.name})" : "")
  end

  def choices
    return [] if choice_set.nil?
    choice_set.choices.sorted
  end

  def choice_set_choices
    catalog.choice_sets.active.sorted
  end

  def custom_permitted_attributes
    %i(choice_set_id)
  end

  # private

  # TODO: validate choice belongs to specified ChoiceSet
  # def build_validators(field, attr)
  # end
end
