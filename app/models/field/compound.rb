class Field::Compound < Field
  store_accessor :options, :template

  def describe
    super.merge(
      template: template
    )
  end

  def value_for_item(item)
    sql_value(item)
  end

  def sql_value(item)
    presenter = Field::CompoundPresenter.new(
      ApplicationController.new,
      item,
      self,
      {},
      false
    )

    if i18n?
      translations = {}
      item_type.catalog.valid_locales.each do |locale|
        translations[locale.to_s] = presenter.value(locale: locale).gsub(/[[:space:]]/) { ' ' }
      end

      return sql_escape_formatted(
        JSON.generate(translations)
      )
    end

    sql_escape_formatted(
      presenter.value.gsub(/[[:space:]]/) { ' ' }
    )
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

  def csv_value(item, user=nil)
    Field::CompoundPresenter.new(ApplicationController.new, item, self, {}, user).value.to_s
  end

  def raw_value(item, locale=I18n.locale, suffix="")
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
