class FieldPresenter
  attr_reader :view, :item, :field, :options, :user

  delegate :t, :to => I18n
  delegate :uuid, :comment, :to => :field
  delegate :label, to: :field, prefix: :field
  delegate :react_component, :to => :view

  # Returns the options hash that will be given to the FieldPresenter
  # constructor when rendering this item for an item view.
  #
  # If you need to give specific options to a presenter when rendering
  # it from an item view, you can override this method in the subclass.
  #
  # @param _view_type The view type that is being rendered.
  #                   See ItemViewPresenter.VIEW_TYPES.
  def self.options_for_item_view(_view_type)
    {}
  end

  def initialize(view, item, field, options={}, user=nil)
    @view = view
    @item = item
    @field = field
    @options = options
    @user = user
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
    field.raw_value(item)
  end

  private

  def compact?
    options[:style] == :compact
  end

  def input_defaults(options)
    data = input_data_defaults(options.fetch(:data, {}))

    options.reverse_merge(
      :label => field_label,
      :data => data,
      :help => comment,
      :include_blank => !field.required
    )
  end

  def input_data_defaults(data)
    return data unless field.belongs_to_category?

    data.reverse_merge(
      "field-category" => field.category_id,
      "field-category-choice-id" => field.category_choice_id,
      "field-category-choice-set-id" => field.category_choice_set_id
    )
  end
end
