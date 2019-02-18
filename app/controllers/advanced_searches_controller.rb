# == Schema Information
#
# Table name: advanced_searches
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  creator_id   :integer
#  criteria     :json
#  id           :integer          not null, primary key
#  item_type_id :integer
#  locale       :string           default("en"), not null
#  updated_at   :datetime         not null
#  uuid         :string
#

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
    @advanced_search_results = ItemList::AdvancedSearchResult.new(
      :model => @saved_search,
      :page => params[:page]
    )
  end

  private

  def build_advanced_search
    type = catalog.item_types.where(:slug => params[:type]).first
    @advanced_search = scope.new do |model|
      model.item_type = type || catalog.item_types.sorted.first
      model.creator = current_user if current_user.authenticated?
    end
  end

  def find_advanced_search_or_redirect
    @saved_search = scope.where(:uuid => params[:uuid]).first
    redirect_to(:action => :new) if @saved_search.nil?
  end

  def advanced_search_params
    search = ItemList::AdvancedSearchResult.new(:model => @advanced_search)
    search.permit_criteria(params.require(:advanced_search))
  end

  def scope
    catalog.advanced_searches
  end
end
