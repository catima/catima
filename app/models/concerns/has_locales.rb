module HasLocales
  extend ActiveSupport::Concern

  module ClassMethods
    def locales(*attrs)
      attrs.each do |attr|
        define_method(attr) do |locale=I18n.locale|
          val = JSON.parse(self[attr])
          val[locale.to_s] || ''
        end

        define_method(:"#{attr}_json") do
          JSON.parse(self[attr])
        end

        define_method(:"#{attr}_str") do
          self[attr]
        end
      end
    end
  end
end
