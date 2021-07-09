class API::V3::Catalog::ChoiceSetsController < API::V3::Catalog::BaseController
  before_action :find_choice_sets

  def index
    @choice_sets = @choice_sets.page(params[:page] ).per(params[:per] || DEFAULT_PAGE_SIZE)
  end

  private

  def find_choice_sets
    @choice_sets = @catalog.choice_sets
  end
end
