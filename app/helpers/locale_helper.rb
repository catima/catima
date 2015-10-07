module LocaleHelper
  def current_locale_language
    locale_language(I18n.locale)
  end

  def locale_language(locale)
    case locale.to_s
    when "de" then "Deutsch"
    when "fr" then "Français"
    when "it" then "Italiano"
    else "English"
    end
  end

  def locale_language_choices
    I18n.available_locales.sort.map do |locale|
      [locale, locale_language(locale), locale == I18n.locale]
    end
  end
end
