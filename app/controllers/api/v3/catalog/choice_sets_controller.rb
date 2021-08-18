class API::V3::Catalog::ChoiceSetsController < API::V3::Catalog::BaseController
  before_action :find_choice_sets

  after_action -> { set_pagination_header(:choice_sets) }, only: :index

  def index
    authorize(@catalog, :choice_sets_index?) unless authenticated_catalog?

    @choice_sets = @choice_sets.page(params[:page]).per(params[:per])
  end

  private

  def find_choice_sets
    @choice_sets = @catalog.choice_sets
  end
end
