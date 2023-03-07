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
  validate :type_validation

  delegate :choices, :choice_prefixed_label, :flat_ordered_choices, to: :choice_set

  def type_name
    "Choice set" + (choice_set ? " (#{choice_set.name})" : "")
  end

  def choices
    return Choice.none if choice_set.nil?

    choice_set.choices.sorted
  end

  def choice_set_choices
    catalog.choice_sets.default.not_deactivated.not_deleted.sorted
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

  def order_items_by(direction: 'ASC', nulls_order: 'LAST')
    "(choices.short_name_translations->>'short_name_#{I18n.locale}') #{direction} NULLS #{nulls_order}" unless choices.nil?
  end

  def allows_unique?
    false
  end

  def search_data_as_hash
    choices_as_options = []

    flat_ordered_choices.each do |choice|
      choices_as_options << formated_choice(choice)
    end

    choices_as_options
  end


  def formated_choice(choice)
    option = {
      value: choice.short_name,
      id: choice.id,
      key: choice.id,
      label: choice_prefixed_label(choice),
      has_childrens: choice&.childrens&.any?,
      uuid: choice.uuid,
      name: choice.choice_set.choice_prefixed_label(choice, with_dates: choice.choice_set&.datation?),
      category_id: choice.category_id,
      choice_set_id: choice.choice_set.id,
      short_name: choice.short_name,
      long_name: choice.long_name,
      from_date: choice.from_date,
      to_date: choice.to_date
    }

    option[:category_data] = choice.category.present? && choice.category.not_deleted? ? choice.category.fields : []
    option
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

  def edit_props(item)
    {
      choiceSet: {
        name: choice_set.name,
        uuid: choice_set.uuid,
        id: choice_set.id,
        format: choice_set.format.to_json,
        multiple: multiple?,
        allowBC: choice_set.allow_bc,
        newChoiceModalUrl: Rails.application.routes.url_helpers.new_choice_modal_catalog_admin_choice_set_path(catalog, I18n.locale, choice_set),
        createChoiceUrl: Rails.application.routes.url_helpers.catalog_admin_choice_set_choices_path(catalog, I18n.locale, choice_set),
        fetchUrl: fetch_url,
        selectedChoicesValue: selected_choices(item[:item]).map do |choice|
          {
            label: choice.choice_set.choice_prefixed_label(choice, with_dates: false),
            value: choice.id,
            category_id: choice.category_id,
            id: choice.id,
            choice_set_id: choice.choice_set_id
          }
        end
      },
      locales: choice_set.catalog.valid_locales,
      fieldUuid: uuid,
      req: required,
      errorMsg: I18n.t("errors.messages.blank")
    }
  end

  private

  def fetch_url
    if item_type.is_a?(ItemType)
      Rails.application.routes.url_helpers.react_choices_for_choice_set_path(
        catalog.slug,
        I18n.locale,
        item_type.slug,
        field_uuid: uuid,
        choice_set_id: choice_set.id
      )
    elsif item_type.is_a?(Category)
      Rails.application.routes.url_helpers.react_category_choices_for_choice_set_path(
        catalog.slug,
        I18n.locale,
        item_type.id,
        field_uuid: uuid,
        choice_set_id: choice_set.id
      )
    else
      ""
    end
  end

  # Should return true if the choice set holds a choice linked to
  # a category, false otherwise.
  def linked_category?
    return true if choices.any? do |choice|
      choice.category.present? && choice.category.not_deleted?
    end

    false
  end

  def type_validation
    return if choice_set_id.blank?

    # Validate selected ChoiceSet has the "default" type
    return if ::ChoiceSet.find(choice_set_id).default?

    errors.add(:choice_set_id, "Only ChoiceSet with the \"default\" type is allowed")
  end
end
