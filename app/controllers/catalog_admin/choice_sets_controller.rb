class CatalogAdmin::ChoiceSetsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"

  def index
    authorize(ChoiceSet)
    @choice_sets = catalog.choice_sets.sorted
    render("index", :layout => "catalog_admin/setup")
  end

  # def new
  #   build_choice_set
  #   authorize(@choice_set)
  # end

  # def create
  #   build_choice_set
  #   authorize(@choice_set)
  #   if @choice_set.update(choice_set_params)
  #     redirect_to(catalog_admin_choice_sets_path, :notice => choice_set_created_message)
  #   else
  #     logger.debug(@choice_set.errors.inspect)
  #     render("new")
  #   end
  # end

  # def edit
  #   find_choice_set
  #   authorize(@choice_set)
  # end

  # def update
  #   find_choice_set
  #   authorize(@choice_set)
  #   if @choice_set.update(choice_set_params)
  #     redirect_to(catalog_admin_choice_sets_path, :notice => choice_set_updated_message)
  #   else
  #     render("edit")
  #   end
  # end

  # private

  # def build_choice_set
  #   @choice_set = ChoiceSet::InvitationForm.new(
  #     :catalog => catalog,
  #     :invited_by => current_choice_set
  #   )
  # end

  # def find_choice_set
  #   @choice_set = ChoiceSet.find(params[:id])
  # end

  # def choice_set_params
  #   policy(@choice_set).permit(...)
  # end

  # def choice_set_created_message
  #   "An invitation has been sent to #{@choice_set.email}."
  # end

  # def choice_set_updated_message
  #   "#{@choice_set.email} has been saved."
  # end
end
