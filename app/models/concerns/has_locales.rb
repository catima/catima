module HasLocales
  extend ActiveSupport::Concern

  module ClassMethods
    def locales(*attrs)
      attrs.each do |attr|
        define_getter_locale(attr)
        define_getter_json(attr)
        define_getter_str(attr)
      end
    end

    def define_getter_locale(attr)
      define_method(attr) do |locale=I18n.locale|
        raw_value = self[attr] || {}
        return raw_value[locale.to_s] || '' if raw_value.instance_of?(Hash)

        val = JSON.parse(raw_value || '{}')

        # If value for current locale is not available,
        # get the first available value
        locale, = val.first unless val[locale.to_s]

        val[locale.to_s] || ''
      end
    end

    def define_getter_json(attr)
      define_method(:"#{attr}_json") do
        raw_value = self[attr] || {}
        return raw_value || {} if raw_value.instance_of?(Hash)

        JSON.parse(raw_value || '{}')
      end
    end

    def define_getter_str(attr)
      define_method(:"#{attr}_str") do
        raw_value = self[attr] || ''
        return JSON.dump(raw_value) if raw_value.instance_of?(Hash)

        raw_value
      end
    end
  end
end
