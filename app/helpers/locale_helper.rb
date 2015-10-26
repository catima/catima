require "ostruct"

module LocaleHelper
  def current_locale_language
    locale_language(I18n.locale)
  end

  def current_locale_flag_and_language
    locale_flag_and_language(I18n.locale)
  end

  def locale_language(locale)
    case locale.to_s
    when "de" then "Deutsch"
    when "fr" then "Français"
    when "it" then "Italiano"
    else "English"
    end
  end

  def locale_flag(locale)
    retina_image_tag("flags/#{locale}", :alt => locale_language(locale))
  end

  def locale_flag_and_language(locale)
    [locale_flag(locale), locale_language(locale)].join(" ").html_safe
  end

  def locale_language_choices
    I18n.available_locales.sort.map do |locale|
      [locale, locale_language(locale), locale == I18n.locale]
    end
  end

  def locale_language_check_boxes(form, method, options={})
    form.collection_check_boxes(
      method,
      locale_language_choices.map(&:first).map(&:to_s),
      :itself,
      ->(choice) { locale_flag_and_language(choice) },
      options
    )
  end

  def locale_language_select(form, method, options={}, html_options={})
    form.collection_select(
      method,
      locale_language_choices.map(&:first).map(&:to_s),
      :itself,
      ->(choice) { locale_language(choice) },
      options,
      html_options
    )
  end
end
