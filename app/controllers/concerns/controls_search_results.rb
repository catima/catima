module ControlsSearchResults
  extend ActiveSupport::Concern

  included do
    helper_method :search
  end

  private

  def search
    return advanced_search if params[:search].present?
    return simple_search if params[:q].present?
  end

  def advanced_search
    model = catalog.advanced_searches.where(:uuid => params[:search]).first
    return nil if model.nil?
    @search ||= Search::Advanced.new(:model => model)
  end

  def simple_search
    @search ||= Search::Simple.new(
      :catalog => catalog,
      :query => params[:q],
      :item_type_slug => params[:item_type_slug]
    )
  end
end
