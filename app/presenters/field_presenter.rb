class FieldPresenter
  attr_reader :view, :item, :field
  delegate :t, :to => I18n
  delegate :uuid, :to => :field

  def initialize(view, item, field)
    @view = view
    @item = item
    @field = field
  end

  def label
    field.name_primary
  end

  def help
    i18n_key = field.model_name.i18n_key
    t("helpers.help.#{i18n_key}")
  end

  def value
    return nil if raw_value.blank?
    raw_value
  end

  def raw_value
    item.behaving_as_type.send(field.uuid)
  end

  private

  def input_defaults(options)
    options.reverse_merge(:label => label)
  end
end
