# Defines how an Item's data is stored in its JSON data column. The format
# varies depending on whether the data is localized, multivalued, both, or
# neither. Coerces between these formats gracefully, since an Item's schema
# definition may change over time.
#
# Note that in-memory the format is a Ruby Hash; ActiveRecord takes care of
# serializing to JSON when it is saved to the database.
#
# Here are the formats:
#
#   Single value, not localized
#   "key" => "value"
#
#   Single value, localized
#   "key" => {
#     "_translations" => {
#       "en" => "english",
#       "it" => "italiano"
#     }
#   }
#
#   Multivalued, not localized
#   "key" => ["one", "two"]
#
#   Multivalued, localized
#   "key" => {
#     "_translations" => {
#       "en" => ["one", "two"],
#       "it" => ["uno", "due"]
#     }
#   }
#
class DataStore
  attr_reader :data, :key, :locale

  def initialize(data:, key:, multivalued:, locale:)
    @data = data
    @key = key.to_s
    @multivalued = multivalued
    @locale = locale ? locale.to_s : nil
  end

  def localized?
    !locale.nil?
  end

  def multivalued?
    @multivalued
  end

  def get
    multivalued? ? all_in_locale : all_in_locale.first
  end

  def set(value)
    data[key] = localized? ? merge_translation(value) : value
    value
  end

  private

  def all_in_locale
    Array.wrap(translate(data[key]))
  end

  def translate(value)
    translations = corerce_to_locale_hash(value)
    localized? ? translations[locale] : translations.values.compact.first
  end

  def corerce_to_locale_hash(value)
    if value.is_a?(Hash) && value.key?("_translations")
      value["_translations"]
    else
      { locale => value }
    end
  end

  def merge_translation(value)
    existing = corerce_to_locale_hash(data[key])
    { "_translations" => existing.merge(locale => value) }
  end
end
