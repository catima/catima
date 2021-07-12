class API::V3::Catalog::ChoiceSet::ChoicesController < API::V3::Catalog::ChoiceSet::BaseController
  def index
    @choices = @choice_set.choices.where(parent_id: nil).page(params[:page]).per(params[:per] || DEFAULT_PAGE_SIZE)
  end

  def show
    @choice = @choice_set.choices.find(params[:choice_id])
  end
end
