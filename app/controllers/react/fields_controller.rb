class React::FieldsController < React::BaseController
  include ControlsItemSorting
  include ChoiceSetsHelper
  before_action :catalog_request_clearance

  InvalidItemType = Class.new(RuntimeError)
  InvalidField = Class.new(RuntimeError)

  rescue_from InvalidItemType, InvalidField do |exception|
    status = 400
    error = {
      :status => status,
      :error => "Bad request",
      :message => exception.message
    }
    render(:json => error, :status => status)
  end

  # Mainly used to get the fields of an ItemType
  # or a Category in the advanced search react components
  def index
    it = item_type
    category = find_category
    field = find_field(it, category)

    input_data = field.search_data_as_hash
    if field.is_a?(Field::ChoiceSet)
      input_data = !field.choice_set.not_deleted? || !field.choice_set.not_deactivated? ? [] : filter_category_fields(field.search_data_as_hash)
    end

    render(json:
             {
               slug: it&.slug,
               name: it&.name,
               search_placeholder: t("catalog_admin.items.reference_editor.reference_editor_search", locale: params[:locale]),
               filter_placeholder: t("catalog_admin.items.reference_editor.reference_editor_filter", locale: params[:locale]),
               selectCondition: field.search_conditions_as_hash(params[:locale]),
               displayFieldCondition: true,
               inputType: field.type,
               inputData: input_data,
               inputOptions: field.search_options_as_hash
             })
  end

  def category_choices_for_choice_set
    item_type = find_category
    choices_for_item_type(item_type)
  end

  def choices_for_choice_set
    raise InvalidItemType, 'no item type provided' if item_type.nil?

    choices_for_item_type(item_type)
  end

  private

  def choices_for_item_type(item_type)
    field = item_type.fields.find_by(:uuid => params[:field_uuid])
    choice_set = field.is_a?(Field::ComplexDatation) ? ChoiceSet.where(id: field.choice_set_ids).find(params[:choice_set_id]) : field
    choices = choice_set.flat_ordered_choices

    if params[:search]
      choices = choices.where(
        "LOWER(choices.short_name_translations->>'short_name_#{locale}') LIKE :q OR LOWER(choices.long_name_translations->>'short_name_#{locale}') LIKE :q",
        q: "%#{params[:search].downcase}%"
      ).order(Arel.sql("LOWER(choices.short_name_translations->>'short_name_#{locale}') ASC"))
    end

    choices = choices.page(params[:page]) if params[:page].present?

    render(
      json:
        {
          slug: item_type.id, name: item_type.name,
          select_placeholder: t("catalog_admin.items.reference_editor.reference_editor_select"),
          search_placeholder: t("catalog_admin.items.reference_editor.reference_editor_search"),
          filter_placeholder: t("catalog_admin.items.reference_editor.reference_editor_filter", locale: params[:locale]),
          loading_message: t("loading", locale: params[:locale]),
          choices: filter_category_fields(choices.map { |choice| field.formated_choice(choice) }),
          hasMore: params[:page].present? && params[:page].to_i < choices.total_pages
        }
    )
  end

  def choice_json_attributes(choice)
    {
      id: choice.id,
      uuid: choice.uuid,
      name: choice.choice_set.choice_prefixed_label(choice, with_dates: choice.choice_set&.datation?),
      category_id: choice.category_id,
      choice_set_id: choice.choice_set.id,
      short_name: choice.short_name,
      long_name: choice.long_name,
      from_date: choice.from_date,
      to_date: choice.to_date
    }
  end

  def item_type
    return nil if params[:item_type_slug].blank?

    item_type = catalog.item_types.where(:slug => params[:item_type_slug]).first
    raise InvalidItemType, "item_type not found: #{params[:item_type_slug]}" if item_type.nil?

    item_type
  end

  def find_category
    return nil if params[:category_id].blank?

    category = catalog.categories.where(:id => params[:category_id]).first
    raise InvalidItemType, "category not found: #{params[:category_id]}" if category.nil?

    category
  end

  def find_field(item_type, category)
    return nil if params[:field_uuid].blank?

    if category.blank?
      field = item_type.fields.find_by(:uuid => params[:field_uuid])
      # In case we search for a category field in a reference
      field = item_type.all_fields.select { |fld| fld.slug == params[:field_uuid] }.first if field.nil?
    else
      field = category.fields.find_by(:uuid => params[:field_uuid])
    end

    raise InvalidField, "field not found: #{params[:field_uuid]}" if field.nil?

    field
  end

  def catalog
    @catalog ||= Catalog.find_by!(:slug => params[:catalog_slug])
  end
end
