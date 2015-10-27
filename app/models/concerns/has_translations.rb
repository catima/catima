# Provides an `store_translations` macro that, given a JSON column named
# `<attrib>_translations`, defines accessors and presence validation for
# storing translations of `<attrib>` in that JSON column.
#
# Presence of the names is validated based on the languages supported by the
# catalog (the model must have a `catalog` accessor). For example, if the model
# belongs to a catalog that supports :en and :fr locales, then :en and :fr
# versions of the attribute will be required. Other languages will not be
# validated.
#
# Given this invocation:
#
#   store_translations :name
#
# This will expose accessors in this format, for every supported locale:
#
#   name_#{locale}
#   name_#{locale}=
#
# And a convenience method for the current locale (read-only):
#
#   name # uses I18n.locale
#
# Values are stored in the `name_translations` JSON column in this format:
#
#   {
#     "name_en" => "person",
#     "name_it" => "persona"
#   }
#
module HasTranslations
  extend ActiveSupport::Concern

  included do
    delegate :valid_locale?, :to => :catalog, :allow_nil => true
  end

  module ClassMethods
    def store_translations(*attrs)
      attrs.each do |attr|
        store_accessor :"#{attr}_translations",
                       :"#{attr}_de",
                       :"#{attr}_en",
                       :"#{attr}_fr",
                       :"#{attr}_it"

        define_method(attr) do
          locale = I18n.locale
          locale = catalog.primary_language unless valid_locale?(locale)
          public_send("#{attr}_#{locale}")
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
