class API::V3::Catalog::ChoiceSet::BaseController < API::V3::Catalog::BaseController
  before_action :find_choice_set

  private

  def find_choice_set
    @choice_set = @catalog.choice_sets.not_deleted.not_deactivated.find(params[:choice_set_id])
  end
end
