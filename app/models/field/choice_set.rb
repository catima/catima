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

class Field::ChoiceSet < ::Field
  belongs_to :choice_set, :class_name => "::ChoiceSet"

  # TODO: register validations declaratively like this?
  # item_callbacks do |field, attrib|
  #   before_validation -> { field.strip_empty_values(self) }
  # end

  validates_presence_of :choice_set
  validates_inclusion_of :choice_set,
                         :in => :choice_set_choices,
                         :allow_nil => true

  def type_name
    "Choice set" + (choice_set ? " (#{choice_set.name})" : "")
  end

  def choices
    return Choice.none if choice_set.nil?
    choice_set.choices.sorted
  end

  def choice_set_choices
    catalog.choice_sets.active.sorted
  end

  def custom_field_permitted_attributes
    %i(choice_set_id)
  end

  def selected_choice?(item, choice)
    selected_choices(item).map(&:id).include?(choice.id)
  end

  def selected_choice(item)
    selected_choices(item).first
  end

  def selected_choices(item)
    return [] if raw_value(item).blank?
    choices.except(:order).where(:id => raw_value(item))
  end

  def decorate_item_class(klass)
    super
    field = self
    klass.public_send(:before_validation) do
      field.strip_empty_values(self)
    end
  end

  def strip_empty_values(item)
    values = raw_value(item)
    return unless values.is_a?(Array)
    values.reject!(&:blank?)
  end

  private

  # TODO: validate choice belongs to specified ChoiceSet
  # def build_validators(field, attr)
  # end
end
