# Provides an `i18n_accessors` macro that, given a JSON column name, defines
# accessors and presence validation for storing translations in that JSON
# column.
#
# Presence of the names is validated based on the languages supported by the
# catalog (the model must have a `catalog` accessor). For example, if the model
# belongs to a catalog that supports :en and :fr locales, then :en and :fr
# versions of the attribute will be required. Other languages will not be
# validated.
#
# Given this invocation:
#
#   i18n_accessors :name
#
# This will expose accessors in this format, for every supported locale:
#
#   name_#{locale}
#   name_#{locale}=
#
# And convenience methods for the catalog's primary locale and the current
# locale:
#
#   name_primary
#   name_in_locale
#
# Values are stored in the JSON column in this format:
#
#   {
#     "name_en" => "person",
#     "name_it" => "persona"
#   }
#
module HasI18nAccessors
  extend ActiveSupport::Concern

  included do
    delegate :valid_locale?, :to => :catalog, :allow_nil => true
  end

  module ClassMethods
    def i18n_accessors(*attrs)
      attrs.each do |attr|
        store_accessor attr,
                       :"#{attr}_de",
                       :"#{attr}_en",
                       :"#{attr}_fr",
                       :"#{attr}_it"

        define_method("#{attr}_primary") do
          public_send("#{attr}_#{catalog.primary_language}")
        end

        define_method("#{attr}_in_locale") do
          public_send("#{attr}_#{I18n.locale}")
        end

        validates_presence_of :"#{attr}_de",
                              :if => ->(m) { m.valid_locale?(:de) }

        validates_presence_of :"#{attr}_en",
                              :if => ->(m) { m.valid_locale?(:en) }

        validates_presence_of :"#{attr}_fr",
                              :if => ->(m) { m.valid_locale?(:fr) }

        validates_presence_of :"#{attr}_it",
                              :if => ->(m) { m.valid_locale?(:it) }
      end
    end
  end
end
