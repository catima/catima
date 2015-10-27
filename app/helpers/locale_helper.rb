require "ostruct"

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

  def locale_language_check_boxes(form, method, options={})
    form.collection_check_boxes(
      method,
      locale_language_choices.map(&:first).map(&:to_s),
      :itself,
      ->(choice) { locale_language(choice) },
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

  # For a catalog that supports multiple languages, generates a form group
  # with N form fields (one field per supported language). The label is
  # displayed once, and the locale (e.g. "fr") is prefixed to each input.
  #
  # If the catalog only supports one language, builds a single field as if
  # the default form helper was called.
  #
  def locale_form_group(form, method, builder_method, *args)
    locales = form.object.catalog.valid_locales
    return form.public_send(builder_method, method, *args) if locales.one?

    options = args.extract_options!

    form.form_group(method, :label => {}) do
      locales.each_with_object([]) do |locale, inputs|
        method_localized = "#{method}_#{locale}"
        options_localized = options.reverse_merge(
          :hide_label => true,
          :placeholder => locale_language(locale),
          :prepend => locale
        )
        options_localized.delete(:autofocus) unless inputs.empty?

        inputs << form.public_send(
          builder_method,
          method_localized,
          *args,
          options_localized
        )
      end.join("\n").html_safe
    end
  end
end
