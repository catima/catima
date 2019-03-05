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

class Field::ChoiceSet < ::Field
  include ::Field::AllowsMultipleValues

  belongs_to :choice_set, :class_name => "::ChoiceSet"

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

    choices.where(:id => raw_value(item))
  end

  def prepare_value(value)
    k = 'short_name'
    l = catalog.primary_language
    v = value
    if value.is_a? Hash
      k = 'long_name' unless value['long_name'].nil?
      l = value[k].keys[0]
      v = value[k][l].sub("'", "''")
    elsif value.is_a? String
      v = value.sub("'", "''")
    end
    c = choices.where("#{k}_translations->>'#{k}_#{l}'='#{v}'").first
    cid = c.id unless c.nil?
    {uuid => cid}
  end

  def filterable?
    false
  end

  def describe
    super.merge("choice_set": choice_set.uuid)
  end

  def value_for_item(it)
    multiple? ? selected_choices(it) : selected_choice(it)
  end

  def value_or_id_for_item(it)
    if multiple?
      selected_choices(it).map(&:uuid)
    else
      ch = selected_choice(it)
      ch.nil? ? nil : ch.uuid
    end
  end

  def field_value_for_item(it)
    if multiple?
      selected_choices(it).map(&:long_display_name).join(', ')
    else
      ch = selected_choice(it)
      ch.nil? ? nil : ch.long_display_name
    end
  end

  def order_items_by
    "(choices.long_name_translations->>'long_name_#{I18n.locale}') ASC" unless choices.nil?
  end

  def search_data_as_hash
    choices_as_options = []

    choices.each do |choice|
      option = { :value => choice.short_name, :key => choice.id }
      option[:category_data] = choice.filterable_category_fields

      choices_as_options << option
    end

    choices_as_options
  end

  def search_options_as_hash
    [
      { :multiple => multiple? }
    ]
  end

  def field_value_for_all_item(_it)
    choices_as_hash = []

    choices.each do |choice|
      option = { :value => choice.short_name }
      option[:category_name] = choice.category.name if choice.category.present?

      choices_as_hash << option
    end

    choices_as_hash.to_json
  end

  def sql_type
    "INT"
  end

  def search_data_as_hash
    choices_as_options = []

    choices.each do |choice|
      option = { :value => choice.short_name, :key => choice.id }
      option[:category_data] = choice.filterable_category_fields

      choices_as_options << option
    end

    choices_as_options
  end

  def search_options_as_hash
    [
      { :multiple => multiple? }
    ]
  end

  private

  # TODO: validate choice belongs to specified ChoiceSet
  # def build_validators(field, attr)
  # end
end
