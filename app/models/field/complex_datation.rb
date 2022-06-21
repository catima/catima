class Field::ComplexDatation < ::Field
  FORMATS = %w(Y M h YM MD hm YMD hms MDh YMDh MDhm YMDhm MDhms YMDhms).freeze
  ALLOWED_FORMATS = %w(date_time datation_choice).freeze

  store_accessor :options, [:format, :allow_bc, :allowed_formats, :choice_set_ids]
  after_initialize :set_default_format

  validates_inclusion_of :format, :in => FORMATS
  validate :presence_of_allowed_formats
  validate :choice_set_type_validation

  def custom_field_permitted_attributes
    [:format, :allow_bc, { allowed_formats: [], choice_set_ids: [] }]
  end

  def custom_item_permitted_attributes
    (1..6).map { |i| :"#{uuid}_time(#{i}i)" } + [:bc, :datation_choice_set_ids]
  end

  def search_data_as_hash
    choices_as_options = []

    flat_ordered_choices.each do |choice|
      option = { :value => choice.short_name, :key => choice.id, label: choice.choice_set.choice_prefixed_label(choice), has_childrens: choice.childrens.any? }

      choices_as_options << option
    end
    choices_as_options
  end

  def flat_ordered_choices
    @flat_ordered_choices ||= recursive_ordered_choices(catalog.choice_sets.where(id: choice_set_ids).map { |choice_set| choice_set.choices.ordered.reject(&:parent_id?) }.flatten).flatten
  end

  def recursive_ordered_choices(choices, deep: 0)
    choices.flat_map do |choice|
      [choice, recursive_ordered_choices(choice.choice_set.find_sub_choices(choice), deep: deep + 1)]
    end
  end

  def allowed_formats
    super || super&.compact_blank
  end

  def csv_value(item, _user=nil)
    value = raw_value(item)
    case value["selected_format"]
    when 'date_time'
      Field::ComplexDatationPresenter.new(nil, item, self).value
    when 'datation_choice'
      selected_choices(item).map do |c|
        "#{c.short_name} (#{Field::ComplexDatationPresenter.new(nil, item, self).choice_dates(c.from_date, c.to_date, c.choice_set.format, value['selected_choices']['BC'])})"
      end.join('; ')
    else
      ''
    end
  end

  def choice_set_choices
    catalog.choice_sets.datation.not_deactivated.not_deleted.sorted
  end

  def selected_choices(item)
    return [] if raw_value(item)&.[]('selected_choices')&.[]('value').nil?

    Choice.where(id: raw_value(item)['selected_choices']['value']).reject do |choice|
      !choice.choice_set.not_deleted? || !choice.choice_set.not_deactivated?
    end
  end

  def selected_format(item)
    raw_value(item)["selected_format"]
  end

  def sql_type
    "JSON"
  end

  def edit_props(item)
    {
      "fetchUrl" => Rails.application.routes.url_helpers.react_field_complex_datation_choices_url(
        catalog.slug,
        I18n.locale,
        item_type.slug,
        field_uuid: uuid
      ),
      "selectedChoicesValue" => selected_choices(item[:item]).map do |choice| {
        label: choice.choice_set.choice_prefixed_label(choice),
        value: choice.id
      }
      end,
      selectedFormat: allowed_formats
    }
  end

  # Translates YMD.. hash into an array [Y, M, D, h, m, s] (or nil).
  def value_as_array(item, format: "YMDhms", date_name: false, value: false)
    v = value || raw_value(item)
    return nil if v.nil?

    defaults = {}
    format.each_char { |c| defaults[c] = "" }
    defaults.map do |key, default_value|
      date_name ? v[date_name][key] || default_value : JSON.parse(v)[key] || default_value
    end
  end

  # Translates YMD.. hash into an integer number (or nil).
  def value_as_int(item)
    components = value_as_array(item)
    return nil if components.nil?

    (0..(components.length - 1)).collect do |i|
      components[i].to_s.present? ? components[i] * (10**(10 - (2 * i))) : 0
    end.sum
  end

  def field_value_for_item(item)
    field_value(item, self)
  end

  def search_conditions_as_hash(locale)
    [
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.exact", locale: locale), :key => "exact" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.after", locale: locale), :key => "after" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.before", locale: locale), :key => "before" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.between", locale: locale), :key => "between" },
      { :value => I18n.t("advanced_searches.fields.date_time_search_field.outside", locale: locale), :key => "outside" }
    ]
  end

  def search_options_as_hash
    [
      { :format => self.format },
      { :localizedDateTimeData => I18n.t('date') }
    ]
  end

  def allows_unique?
    false
  end

  def groupable?
    false
  end

  def sortable?
    false
  end

  private

  def presence_of_allowed_formats
    return unless !allowed_formats || (allowed_formats.exclude?("date_time") && allowed_formats.exclude?("datation_choice"))

    errors.add(:allowed_formats, :empty)
  end

  def choice_set_type_validation
    return unless allowed_formats.include?("datation_choice")

    # Validate that all selected ChoiceSet(s) have the "datation" type
    errors.add(:choice_set_ids, "Only ChoiceSet(s) with the \"datation\" type are allowed") if choice_set_ids.select do |choice_set_id|
      !::ChoiceSet.find(choice_set_id).datation? if choice_set_id.present?
    end.present?
  end

  def transform_value(value)
    return nil if value.nil?
    return value if value.is_a?(Hash) && !value.key?("raw_value")

    value = { "raw_value" => value } if value.is_a?(Integer)
    value["raw_value"].nil? ? nil : value
  end

  def set_default_format
    self.format ||= "YMD"
  end
end
