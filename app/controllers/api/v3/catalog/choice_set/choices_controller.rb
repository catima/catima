class API::V3::Catalog::ChoiceSet::ChoicesController < API::V3::Catalog::ChoiceSet::BaseController
  def index
    @choices = @choice_set.choices.where(parent_id: nil).page(params[:page] || 1).per(params[:per] || 25)
  end

  def show
    @choice = @choice_set.choices.find(params[:choice_id])
  end
end
