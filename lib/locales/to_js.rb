# frozen_string_literal: true

require "erb"

module Locales
  class ToJs < Base
    private

    def file_format
      "js"
    end

    def template_translations
      <<~JS
        export const translations = #{@translations};
      JS
    end

    def template_default
      <<~JS
        import { defineMessages } from 'react-intl';
        const defaultLocale = '#{default_locale}';
        const defaultMessages = defineMessages(#{@defaults});
        export { defaultMessages, defaultLocale };
      JS
    end
  end
end
