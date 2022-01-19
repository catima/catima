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

  validates_presence_of :choice_set_id
  validates_inclusion_of :choice_set,
                         :in => :choice_set_choices,
                         :allow_nil => true

  delegate :choices, :choice_prefixed_label, :flat_ordered_choices, to: :choice_set

  def type_name
    "Choice set" + (choice_set ? " (#{choice_set.name})" : "")
  end

  def choices
    return Choice.none if choice_set.nil?

    choice_set.choices.sorted
  end

  def choice_set_choices
    catalog.choice_sets.not_deactivated.not_deleted.sorted
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
    return [] if raw_value(item).blank? || !choice_set.not_deleted? || !choice_set.not_deactivated?

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

  def human_readable?
    true
  end

  # Considered filterable if the choice set do not holds
  # a choice linked to a category.
  def filterable?
    !linked_category?
  end

  def describe
    super.merge(choice_set: choice_set.uuid)
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
      ch.nil? ? nil : ch.choice_set.choice_prefixed_label(ch, format: :long)
    end
  end

  def order_items_by(direction: 'ASC')
    "(choices.long_name_translations->>'long_name_#{I18n.locale}') #{direction}" unless choices.nil?
  end

  def allows_unique?
    false
  end

  def search_data_as_hash
    choices_as_options = []

    flat_ordered_choices.each do |choice|
      option = {:value => choice.short_name, :key => choice.id, label: choice_prefixed_label(choice), has_childrens: choice.childrens.any?}
      option[:category_data] = choice.category.present? && choice.category.not_deleted? ? choice.category.fields : []

      choices_as_options << option
    end

    choices_as_options
  end

  def search_conditions_as_hash(locale)
    [
      {:value => I18n.t("advanced_searches.text_search_field.exact", locale: locale), :key => "exact"}
    ]
  end

  def search_options_as_hash
    [
      {:multiple => multiple?}
    ]
  end

  def csv_value(it, _user=nil)
    return selected_choices(it).map(&:short_name).join('; ') if multiple?

    ch = selected_choice(it)
    ch.nil? ? '' : ch.short_name
  end

  def sql_type
    "INT"
  end

  private

  # Should return true if the choice set holds a choice linked to
  # a category, false otherwise.
  def linked_category?
    return true if choices.any? do |choice|
      choice.category.present? && choice.category.not_deleted?
    end

    false
  end
end
