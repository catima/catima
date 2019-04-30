class CatalogAdmin::ChoiceSetsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  def index
    authorize(ChoiceSet)
    @choice_sets = catalog.choice_sets.sorted
  end

  def new
    build_choice_set
    authorize(@choice_set)
  end

  def create
    build_choice_set
    authorize(@choice_set)

    @choice_set.assign_attributes(choice_set_params.except(:choices_attributes))
    loop_trough_children(choice_set_params[:choices_attributes])

    if @choice_set.update(choice_set_params.except(:choices_attributes))
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

  def edit
    find_choice_set
    authorize(@choice_set)
  end

  def update
    find_choice_set
    authorize(@choice_set)

    post_choices = []
    post_choices = loop_trough_children(choice_set_params[:choices_attributes], post_choices)
    Choice.delete(@choice_set.choices.reject { |c| post_choices&.include?(c.uuid) })

    if @choice_set.update(choice_set_params.except(:choices_attributes))
      redirect_to(catalog_admin_choice_sets_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  def loop_trough_children(params, post_choices=[], parent=nil)
    return if params.blank?

    params.each do |i, choices_attributes|
      next unless choices_attributes.is_a?(ActionController::Parameters)

      allowed_params = {}
      # Manually allow all numeric params
      choices_attributes.keys.reject { |k| k.to_s.match(/\A\d+\Z/) }.map do |key, _v|
        allowed_params[key] = choices_attributes[key]
      end

      choice = if allowed_params["uuid"].present?
                 Choice.find_by(:uuid => allowed_params["uuid"])
               else
                 Choice.new
               end

      choice.row_order = i
      choice.assign_attributes(allowed_params)
      choice.parent = parent
      choice.catalog = @choice_set.catalog
      choice.uuid = SecureRandom.uuid if choice.uuid.blank?

      post_choices << choice.uuid

      @choice_set.choices << choice

      if i.match?(/\A\d+\Z/)
        loop_trough_children(choices_attributes, post_choices, choice) if i =~ /\A\d+\Z/
      end
    end

    @choice_set.save

    post_choices
  end

  def create_choice
    choice_set = catalog.choice_sets.find(params[:choice_set_id])
    authorize(choice_set)
    choice = choice_set.choices.new
    if choice.update(choice_params)
      render json: {
        catalog: catalog.id, choice_set: choice_set.id,
        choice: choice
      }
    else
      render json: {
        errors: choice.errors.full_messages.join(', '),
        catalog: catalog.id, choice_set: choice_set.id
      }, status: :unprocessable_entity
    end
  end

  def synonyms
    @field = catalog.choice_sets.find(params[:choice_set_id])
  end

  def update_synonyms
    choice_set = catalog.choice_sets.find(params[:choice_set_id])
    authorize(choice_set)

    if params[:choice_synonyms].nil?
      choice_set.choices.each { |c| c.update(:synonyms => nil) }
      return redirect_to :action => :synonyms
    end

    updated_choices = []
    choice_synonym_params.each do |choice_id, synonyms|
      choice = Choice.find_by(:id => choice_id)
      next if choice.nil?

      choice.synonyms = []

      synonyms.each do |_i, synonym_params|
        synonym = {}

        synonym_params.each do |lang, syn|
          synonym[lang] = syn
        end

        choice.synonyms << synonym
      end

      choice.save
      updated_choices << choice
    end

    # Removes synonyms that where not present in the params
    choice_set.choices.each { |c| c.update(:synonyms => nil) unless updated_choices.include?(c) }

    redirect_to :action => :synonyms
  end

  private

  def build_choice_set
    @choice_set = catalog.choice_sets.new
  end

  def find_choice_set
    @choice_set = catalog.choice_sets.find(params[:id])
  end

  def choice_set_params
    params.require(:choice_set).permit(
      :name,
      :deactivated_at,
      :choices_attributes => {})
  end

  def choice_synonym_params
    params.require(:choice_synonyms)
  end

  def choice_params
    params.require(:choice).permit(
      :short_name_de, :short_name_en, :short_name_fr, :short_name_it,
      :long_name_de, :long_name_en, :long_name_fr, :long_name_it
    )
  end

  def created_message
    "Choice set “#{@choice_set.name}” has been created."
  end

  def updated_message
    message = "Choice set “#{@choice_set.name}” has been "
    message << if choice_set_params.key?(:deactivated_at)
                 (@choice_set.active? ? "reactivated." : "deactivated.")
               else
                 "updated."
               end
    message
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_choice_set_path
    else catalog_admin_choice_sets_path(catalog, I18n.locale, @item_type)
    end
  end
end
