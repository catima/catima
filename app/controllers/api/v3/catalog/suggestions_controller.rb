class API::V3::Catalog::SuggestionsController < API::V3::Catalog::BaseController
  include SuggestionsHelper

  after_action -> { set_pagination_header(:suggestions) }, only: :index

  def index
    authorize(@catalog, :suggestions_index?) unless authenticated_catalog?

    @suggestions = catalog_suggestions(@catalog).page(params[:page]).per(params[:per])

    render 'api/v3/catalog/shared/suggestions'
  end
end
