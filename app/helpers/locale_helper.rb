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

  def locale_language_choices(locales=:automatic)
    if locales == :automatic
      locales = catalog_scoped? ? catalog.valid_locales : I18n.available_locales
    end
    locales.sort.map do |locale|
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
    locales = options.fetch(:locales, I18n.available_locales)

    form.collection_select(
      method,
      locale_language_choices(locales).map(&:first).map(&:to_s),
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
    options = args.extract_options!
    locales = form.object.catalog.valid_locales
    group_label = options.delete(:hide_label) ? nil : {}
    group_label[:text] = options[:label] if group_label && options[:label]
    help = options.delete(:help)

    form.form_group(method, :label => group_label, :help => help) do
      locales.each_with_object([]) do |locale, inputs|
        inputs << locale_form_input(
          form,
          method,
          builder_method,
          locale,
          *args,
          options
        )
      end.join("\n").html_safe
    end
  end

  private

  def locale_form_input(form, method, builder_method, locale, *args)
    options = args.extract_options!
    locales = form.object.catalog.valid_locales

    method_localized = "#{method}_#{locale}"
    options_localized = locale_form_input_options(locales, locale, options)

    form.public_send(builder_method, method_localized, *args, options_localized)
  end

  def locale_form_input_options(locales, locale, options)
    options = options.reverse_merge(:hide_label => true)
    if locales.many?
      options.reverse_merge!(
        :placeholder => locale_language(locale),
        :prepend => locale
      )
    end
    options.delete(:autofocus) unless locale == locales.first
    options
  end
end
