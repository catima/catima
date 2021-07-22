class API::V3::Catalog::ChoiceSet::ChoicesController < API::V3::Catalog::ChoiceSet::BaseController

  after_action -> { set_pagination_header(:choices) }, only: :index

  def index
    authorize(@catalog, :choice_set_choices_index?)

    @choices = @choice_set.choices.where(parent_id: nil).page(params[:page]).per(params[:per])
  end

  def show
    authorize(@catalog, :choice_set_choice_show?)

    @choice = @choice_set.choices.find(params[:choice_id])
  end
end
