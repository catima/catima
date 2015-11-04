module ControlsSearchResults
  extend ActiveSupport::Concern

  included do
    helper_method :search
  end

  private

  def search
    # TODO: handle advanced search
    return nil if params[:q].blank?
    @search ||= Search::Simple.new(:catalog => catalog, :query => params[:q])
  end
end
