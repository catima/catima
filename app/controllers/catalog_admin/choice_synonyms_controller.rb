class CatalogAdmin::ChoiceSynonymsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  def index
    @choice_set = catalog.choice_sets.find(params[:choice_set_id])
    render("catalog_admin/choice_sets/synonyms")
  end

  def update
    choice_set = catalog.choice_sets.find(params[:choice_set_id])
    authorize(choice_set)

    if params[:choice_synonyms].nil?
      choice_set.choices.each { |c| c.update(:synonyms => nil) }
      return redirect_to :action => :index
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

      choice.save!
      updated_choices << choice
    end

    # Removes synonyms that where not present in the params
    choice_set.choices.each { |c| c.update(:synonyms => nil) unless updated_choices.include?(c) }

    redirect_to(edit_catalog_admin_choice_set_path(:id => choice_set), :notice => t("catalog_admin.choice_sets.synonyms.updated"))
  end

  private

  def choice_synonym_params
    params.require(:choice_synonyms)
  end
end
