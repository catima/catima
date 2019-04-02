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

class Field::Text < ::Field
  store_accessor :options, :maximum
  store_accessor :options, :minimum
  store_accessor :options, :formatted_text

  # TODO: validate minimum is less than maximum?

  validates_numericality_of :maximum, :minimum,
                            :only_integer => true,
                            :greater_than => 0,
                            :allow_blank => true

  def custom_field_permitted_attributes
    %i(maximum minimum formatted_text)
  end

  def describe
    super.merge({"i18n": i18n})
  end

  def human_readable?
    return false if formatted?

    true
  end

  def filterable?
    true
  end

  def prepare_value(value)
    if value.is_a? Hash
      d = {}
      value.each do |k, v|
        d.merge!({uuid + '_' + k => v}) if catalog.valid_locale?(k)
      end
      return d
    end
    {uuid => value}
  end

  def formatted?
    (options && options['formatted_text'] && options['formatted_text'].to_i) == 1
  end

  def raw_value(item, locale=I18n.locale, suffix="")
    attrib = i18n? ? "#{uuid}_#{locale}#{suffix}" : uuid
    v = item.behaving_as_type.public_send(attrib) if item.behaving_as_type.respond_to?(attrib)
    return v if v.nil? || !formatted?

    begin
      return JSON.parse(v)['content']
    rescue JSON::ParserError
      return v
    end
  end

  def search_conditions_as_options
    options = [
      [I18n.t("advanced_searches.text_search_field.all_words"), "all_words"],
      [I18n.t("advanced_searches.text_search_field.one_word"), "one_word"]
    ]

    return options if formatted?

    # Formatted text can't be exact searched
    options << [I18n.t("advanced_searches.text_search_field.exact"), "exact"]
  end

  def search_conditions_as_hash(locale)
    options = [
      { :value => I18n.t("advanced_searches.text_search_field.all_words", locale: locale), :key => "all_words"},
      { :value => I18n.t("advanced_searches.text_search_field.one_word", locale: locale), :key => "one_word"}
    ]

    return options if formatted?

    options << { :value => I18n.t("advanced_searches.text_search_field.exact", locale: locale), :key => "exact"}
  end

  def sql_type
    if maximum.present?
      maximum = [maximum.to_i, 21_845].max
      # 21845 is the max length of the SQL TEXT type
      return "VARCHAR(#{maximum})" if maximum < 500
    end

    # A primary key must have a max length
    primary? ? "VARCHAR(255)" : "TEXT"
  end

  def sql_default
    return "" if formatted? || sql_type.include?("TEXT")

    super
  end

  private

  def build_validators
    [length_validator].compact
  end

  def length_validator
    opts = { :allow_blank => true }
    opts[:maximum] = maximum.to_i if maximum.to_i > 0
    opts[:minimum] = minimum.to_i if minimum.to_i > 0
    [ActiveModel::Validations::LengthValidator, opts] if opts.size > 1
  end
end
