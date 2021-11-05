class Field::Compound < ::Field
  store_accessor :options, :template

  def custom_field_permitted_attributes
    %i(template)
  end

  def sql_type
    "VARCHAR(512)"
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

  def csv_value(item, current_user=false)
    Field::CompoundPresenter.new(ApplicationController.new, item, self, {}, current_user).value.to_s
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
