class CatalogAdmin::ChoicesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  before_action :find_choice_set
  before_action :build_choice, only: %i(new)
  before_action :find_choice, only: %i(edit destroy update)
  protect_from_forgery :except => [:update_positions]

  def new
  end

  def edit
  end

  def destroy
    @choice.destroy
    redirect_to(edit_catalog_admin_choice_set_path(@choice_set.catalog, I18n.locale, @choice_set), :notice => destroyed_message)
  end

  def update
    if @choice.update(choice_params)
      redirect_to(edit_catalog_admin_choice_set_path(@choice_set.catalog, I18n.locale, @choice_set), :notice => updated_message)
    else
      render("edit")
    end
  end

  def create
    @choice = @choice_set.choices.build(choice_params)
    if @choice.save_with_position(params[:choice][:position])
      if request.xhr?
        render json: {
          catalog: @choice_set.catalog.id, choice_set: @choice_set.id,
          choice: @choice
        }
      else
        redirect_to(edit_catalog_admin_choice_set_path(@choice_set.catalog, I18n.locale, @choice_set), :notice => created_message)
      end
    elsif request.xhr?
      render json: {
        errors: @choice.errors.full_messages.join(', '),
        catalog: @choice_set.catalog.id, choice_set: @choice_set.id
      }, status: :unprocessable_entity
    else
      render("new")
    end
  end

  def update_positions
    params[:positions].each do |data|
      parent = data[:parent_id].present? ? @choice_set.choices.find(data[:parent_id]) : nil
      data[:children_ids].each.with_index do |id, i|
        @choice_set.choices.find(id).update!(position: i + 1, parent: parent)
      end
    end
  end

  private

  def build_choice
    @choice = @choice_set.choices.new
  end

  def find_choice_set
    @choice_set = catalog.choice_sets.find(params[:choice_set_id])
    authorize(@choice_set)
  end

  def find_choice
    @choice = @choice_set.choices.find(params[:id])
  end

  def choice_params
    params.require(:choice).permit(
      :short_name_de, :short_name_en, :short_name_fr, :short_name_it,
      :long_name_de, :long_name_en, :long_name_fr, :long_name_it,
      :category_id,
      :parent_id,
      :position
    )
  end

  def assign_position_and_reorder_choices_on_create
    parent = @choice.parent_id.present? ? @choice_set.choices.find(@choice.parent_id) : nil
    if params[:choice][:position] == 'first'
      @choice.position = 1
      if parent
        parent.childrens.ordered.each_with_index do |choice, index|
          choice.update!(position: index + 2)
        end
      else
        @choice_set.choices.where(parent_id: nil).ordered.each_with_index do |choice, index|
          choice.update!(position: index + 2)
        end
      end
    elsif params[:choice][:position] == 'last'
      last_position = parent ? parent.childrens.count + 1 : @choice_set.choices.where(parent_id: nil).count + 1
      @choice.position = last_position
    end
  end

  def created_message
    "Choice “#{@choice.short_name}” has been created."
  end

  def destroyed_message
    "Choice “#{@choice.short_name}” has been destroyed."
  end

  def updated_message
    "Choice “#{@choice.short_name}” has been updated."
  end

  def after_create_path
    case params[:commit]
    when /another/i
      new_catalog_admin_choice_set_path
    else
      catalog_admin_choice_sets_path(catalog, I18n.locale, @item_type)
    end
  end
end
