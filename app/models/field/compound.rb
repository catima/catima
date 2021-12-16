class Field::Compound < ::Field
  store_accessor :options, :template

  def describe
    super.merge(
      'template': template
    )
  end

  def value_for_item(it)
    sql_value(it)
  end

  def sql_value(item)
    return Field::CompoundPresenter.new(ApplicationController.new, item, self, {}, false).value.to_s unless i18n?

    value = {'_translations': {}}
    item_type.catalog.valid_locales.each do |locale|
      value[:'_translations'][locale.to_s] = Field::CompoundPresenter.new(ApplicationController.new, item, self, {}, false).value(locale: locale).to_s
    end
    return {'_translations': translation_values(item)}.stringify_keys
  end

  def translation_values(item, user = nil)
    value = {}
    item_type.catalog.valid_locales.each do |locale|
      value[locale.to_s] = Field::CompoundPresenter.new(ApplicationController.new, item, self, {}, user).value(locale: locale).to_s
    end
    value
  end

  def sql_type
    return "JSON" if i18n?

    "TEXT"
  end

  def i18n?
    item_type.catalog.valid_locales.size > 1
  end

  def custom_field_permitted_attributes
    %i(template)
  end

  def human_readable?
    false
  end

  def allows_unique?
    false
  end

  def allows_style?
    false
  end

  def csv_value(item, user = nil)
    Field::CompoundPresenter.new(ApplicationController.new, item, self, {}, user).value.to_s
  end

  def raw_value(item, locale = I18n.locale, suffix = "")
    attrib = i18n? ? "#{uuid}_#{locale}#{suffix}" : uuid
    v = item.behaving_as_type.public_send(attrib) if item.behaving_as_type.respond_to?(attrib)
    return v if v.nil? || !formatted?

    begin
      JSON.parse(v)['content']
    rescue JSON::ParserError
      v
    end
  end
end
