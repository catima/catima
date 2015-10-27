# Assuming a model with JSON columns `name` and `name_plural`, this mixin
# defines accessors and presence validators for storing translations in those
# JSON columns.
#
# Presence of the names is validated based on the languages supported by the
# catalog (the model must have a `catalog` accessor). For example, if the model
# belongs to a catalog that supports :en and :fr locales, then :en and :fr
# versions of the names will be required. Other languages will not be validated.
#
# Exposes accessors in this format, for every supported locale:
#
#   name_#{locale}
#   name_#{locale}=
#   name_plural_#{locale}
#   name_plural_#{locale}
#
# And convenience methods for the catalog's primary locale and the current
# locale:
#
#   name_primary
#   name_plural_primary
#   name_in_locale
#   name_plural_in_locale
#
# Values are stored in the JSON column in this format:
#
#   `name` column:
#   {
#     "name_en" => "person",
#     "name_it" => "persona"
#   }
#
#   `name_plural` column:
#   {
#     "name_plural_en" => "people",
#     "name_plural_it" => "persone"
#   }
#
module HasI18nNames
  extend ActiveSupport::Concern

  included do
    delegate :valid_locale?, :to => :catalog, :allow_nil => true

    store_accessor :name, :name_de, :name_en, :name_fr, :name_it
    store_accessor :name_plural,
                   :name_plural_de, :name_plural_en,
                   :name_plural_fr, :name_plural_it

    validates_presence_of :catalog

    validates_presence_of :name_de, :if => ->(m) { m.valid_locale?(:de) }
    validates_presence_of :name_en, :if => ->(m) { m.valid_locale?(:en) }
    validates_presence_of :name_fr, :if => ->(m) { m.valid_locale?(:fr) }
    validates_presence_of :name_it, :if => ->(m) { m.valid_locale?(:it) }

    validates_presence_of :name_plural_de, :if => ->(m) { m.valid_locale?(:de) }
    validates_presence_of :name_plural_en, :if => ->(m) { m.valid_locale?(:en) }
    validates_presence_of :name_plural_fr, :if => ->(m) { m.valid_locale?(:fr) }
    validates_presence_of :name_plural_it, :if => ->(m) { m.valid_locale?(:it) }
  end

  def name_primary
    public_send("name_#{catalog.primary_language}")
  end

  def name_plural_primary
    public_send("name_plural_#{catalog.primary_language}")
  end

  def name_in_locale
    public_send("name_#{I18n.locale}")
  end

  def name_plural_in_locale
    public_send("name_plural_#{I18n.locale}")
  end
end
