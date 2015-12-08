# Adds the following class-level macros:
#
#   data_store_attribute
#   data_store_validator
#   data_store_hash
#
# The `data_store_attribute` macro defines accessors for getting and setting
# data within an Item's JSON data. While the DataStore class handles the actual
# storage logic, this mixin provides the meta-programming magic that allows us
# to define accessors to that storage on the fly.
#
# For example:
#
#   data_store_attribute :foo
#
# This will define `foo` and `foo=` methods for getting and setting the "foo"
# attribute within the JSON data. By default, the attribute will not be
# localized and will be single-valued.
#
# The macro also accepts options:
#
#   data_store_attribute :foo, :i18n => true, :multiple => true
#
# If :i18n is true, a pair of methods will be created per locale. Furthermore,
# a read-only attribute will be created that implicitly uses the current locale.
#
#   foo     # Implicit: use current locale
#   foo_de
#   foo_de=
#   foo_en
#   foo_en=
#   etc.
#
# Validations can also be attached to an attribute, with automatic handling
# of the multiple i18n values:
#
#   data_store_validator :foo, MyValidatorClass, validator_opts, :i18n => true
#
# This will run the validator against all the locales supported by the catalog.
#
# Also, a special `data_store_hash` macro allows a hash of data to be stored
# in the attribute, rather than a normal value. Accessors will be created for
# each of the specified keys. This is typically used to support refile
# attachments.
#
#   data_store_hash :foo, :id, :filename
#
# This generates the following accessors, which put their values in the "foo"
# entry of the data store:
#
#   foo_id
#   foo_id=
#   foo_filename
#   foo_filename=
#
# Finally, all accessors defined using these macros are exposed via a
# `data_store_attributes` class method.
#
#   data_store_attributes # => [:foo]
#
module DataStore::Macros
  extend ActiveSupport::Concern

  module ClassMethods
    def data_store_attribute(key, i18n:false, multiple:false)
      if i18n
        data_store_attribute_i18n(key, multiple)
      else
        data_store_attribute_basic(key, multiple)
      end
    end

    def data_store_hash(key, *attributes)
      attributes.each do |attr|
        data_store_attributes << :"key_#{attr}"

        define_method("#{key}_#{attr}") do
          data_store_hash(key)[attr.to_s]
        end

        define_method("#{key}_#{attr}=") do |value|
          data_store_hash(key)[attr.to_s] = value
        end

        # Refile needs this
        define_method("#{key}_#{attr}_will_change!") { nil }
      end
    end

    def data_store_validator(key,
                             validator,
                             options={},
                             i18n:false,
                             prerequisite:nil)
      validate do
        next if prerequisite && !prerequisite.call(self)
        attrs = i18n ? catalog.valid_locales.map { |l| "#{key}_#{l}" } : [key]
        validates_with(validator, options.merge(:attributes => attrs))
      end
    end

    def data_store_attributes
      @data_store_attributes ||= []
    end

    private

    def data_store_attribute_i18n(key, multiple)
      define_method(key) do
        dirty_aware_store(key, multiple, true).get
      end

      I18n.available_locales.each do |locale|
        data_store_attributes << :"#{key}_#{locale}"

        define_method("#{key}_#{locale}") do
          dirty_aware_store(key, multiple, true, locale).get
        end

        define_method("#{key}_#{locale}=") do |value|
          dirty_aware_store(key, multiple, true, locale).set(value)
        end
      end
    end

    def data_store_attribute_basic(key, multiple)
      data_store_attributes << key.to_sym

      define_method(key) do
        dirty_aware_store(key, multiple).get
      end

      define_method("#{key}=") do |value|
        dirty_aware_store(key, multiple).set(value)
      end
    end
  end

  def data_store_attributes
    self.class.data_store_attributes
  end

  private

  def data_store_hash(key)
    store = dirty_aware_store(key)
    store.get || store.set({})
  end

  def dirty_aware_store(key, multivalued=false, i18n=false, locale=nil)
    self.data ||= {}
    DataStore::DirtyAwareStore.new(
      :item => self,
      :key => key,
      :locale => (i18n ? locale || I18n.locale : nil),
      :multivalued => multivalued
    )
  end
end
