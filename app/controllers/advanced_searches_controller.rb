class AdvancedSearchesController < ApplicationController
  include ControlsCatalog

  def new
    build_advanced_search
  end

  def create
    build_advanced_search
    if @advanced_search.update(advanced_search_params)
      redirect_to(:action => :show, :uuid => @advanced_search)
    else
      render("new")
    end
  end

  def show
    find_advanced_search_or_redirect
  end

  private

  def build_advanced_search
    @advanced_search = scope.new do |model|
      model.item_type = catalog.item_types.sorted.first
      model.creator = current_user if current_user.authenticated?
    end
  end

  def find_advanced_search_or_redirect
    model = scope.where(:uuid => params[:uuid]).first
    redirect_to(:action => :new) if model.nil?

    @search = Search::Advanced.new(:model => model, :page => params[:page])
  end

  def advanced_search_params
    # TODO
    params.require(:advanced_search).permit(:criteria)
  end

  def scope
    catalog.advanced_searches
  end
end
