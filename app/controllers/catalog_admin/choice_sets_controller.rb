class CatalogAdmin::ChoiceSetsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  def index
    authorize(ChoiceSet)
    @choice_sets = catalog.choice_sets.not_deleted.sorted
  end

  def new
    build_choice_set
    authorize(@choice_set)
  end

  def edit
    find_choice_set
    authorize(@choice_set)
  end

  def create
    build_choice_set
    authorize(@choice_set)
    if @choice_set.update(choice_set_params)
      if request.xhr?
        render json: { choice_set: @choice_set }
      else
        redirect_to(after_create_path, :notice => created_message)
      end
    else
      if request.xhr?
        render json: { errors: @choice_set.errors.full_messages.join(', ') }, status: :unprocessable_entity
      else
        render("new")
      end
    end
  end

  def update
    find_choice_set
    authorize(@choice_set)
    if @choice_set.update(choice_set_params.except(:choice_set_type, :format))
      redirect_to(catalog_admin_choice_sets_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_choice_set
    authorize(@choice_set)
    @choice_set.touch(:deleted_at)
    redirect_to(catalog_admin_choice_sets_path, notice: deleted_message)
  end

  def export
    find_choice_set
    authorize(@choice_set)

    export = @choice_set.attributes
                        .slice(
                          'name',
                          'deactivated_at',
                          'slug',
                          'deleted_at',
                          'choice_set_type',
                          'format',
                          'allow_bc'
                        )

    export["choices"] = @choice_set.choices.map do |c|
      c.attributes
       .slice(
         'short_name_translations',
         'long_name_translations',
         'category_id',
         'parent_id',
         'position',
         'from_date',
         'to_date'
       )
    end
    export.to_json

    send_data export.to_json,
              :type => :json,
              :filename => @choice_set.name.parameterize << '.json',
              :disposition => "attachment"
  end

  def new_import
    build_choice_set
    authorize(@choice_set)
  end

  def import_choice_set
    if params[:file]
      begin
        ChoiceSet.transaction do
          choice_params = JSON.parse(params[:file].read)

          @choice_set = @catalog.choice_sets.new(choice_params.reject { |k, _| k == 'choices' })
          authorize(@choice_set)

          choice_params["choices"].each do |choice|
            c = @choice_set.choices.new(choice.merge(catalog_id: @choice_set.catalog_id))
            c.parent_id = nil
          end
          @choice_set.save!

          choice_params["choices"].reject { |params| params['parent_id'].nil? }.each do |choice|
            c = @choice_set
                .choices
                .where(
                  "short_name_translations::jsonb @> (?::jsonb)",
                  choice["short_name_translations"].to_json
                ).first

            c.parent_id = @choice_set
                          .choices
                          .where(
                            "short_name_translations::jsonb @> (?::jsonb)",
                            Choice.find(choice["parent_id"]).short_name_translations.to_json
                          )&.first&.id
            c.save
          end

          flash[:notice] = t(".success")
        end

        redirect_to catalog_admin_choice_sets_path
      rescue StandardError => e
        flash[:alert] = e.message
        render :new_import
      end
    else
      flash[:alert] = "no file provided"
      render :new_import
    end
  end

  def new_choice_modal
    find_choice_set
    render json: {
      catalog: @choice_set.catalog_id,
      choice_set: @choice_set.id,
      choices: @choice_set.choices.map do |choice|
        {
          id: choice.id,
          name: choice.choice_set.choice_prefixed_label(choice, with_dates: @choice_set.datation?)
        }
      end,
      categories: @choice_set.catalog.categories.sorted.pluck(:id, :name)
    }
  end

  private

  def build_choice_set
    @choice_set = catalog.choice_sets.new
  end

  def find_choice_set
    @choice_set = catalog.choice_sets.not_deleted.find(params[:id])
  end

  def choice_set_params
    params.require(:choice_set).permit(
      :name,
      :choice_set_type,
      :format,
      :deactivated_at,
      :allow_bc,
      :choices_attributes => %i[
        id _destroy
        category_id
        short_name_de short_name_en short_name_fr short_name_it
        long_name_de long_name_en long_name_fr long_name_it
        from_date to_date
      ])
  end

  def created_message
    "Choice set “#{@choice_set.name}” has been created."
  end

  def updated_message
    message = "Choice set “#{@choice_set.name}” has been "
    message << if choice_set_params.key?(:deactivated_at)
                 (@choice_set.not_deactivated? ? "reactivated." : "deactivated.")
               else
                 "updated."
               end
    message
  end

  def deleted_message
    "Choice set “#{@choice_set.name}” has been deleted."
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_choice_set_path
    else catalog_admin_choice_sets_path(catalog, I18n.locale, @item_type)
    end
  end
end
