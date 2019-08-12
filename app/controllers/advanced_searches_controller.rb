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
    @advance_search_confs = @catalog.advanced_search_configurations
    build_advanced_search
    find_advanced_search_configuration

    if @advanced_search_config.present?
      @item_types = @advanced_search_config.item_types
      @fields = @advanced_search_config.field_set

      # Initial display of map
      if @advanced_search_config.search_type_map?
        params[:item_type] = @advanced_search_config.item_type.slug
        build_advanced_search
        @search = ItemList::AdvancedSearchResult.new(
          :model => @advanced_search
        )
      end
    else
      @item_types = @advanced_search.item_types.order(:slug => :asc)

      if @item_types.blank?
        # If no item_type is available, redirect to catalog homepage with a warning
        return redirect_to catalog_home_path, :alert => t('errors.messages.advanced_searches.not_available')
      end

      @fields = @advanced_search.fields

      return redirect_to :action => :new, :item_type => @item_types.first if params[:item_type].blank?
    end
  end

  def create
    build_advanced_search
    if @advanced_search.update(advanced_search_params)
      respond_to do |f|
        f.html { redirect_to(:action => :show, :uuid => @advanced_search) }
        f.js do
          params[:uuid] = @advanced_search.uuid
          find_advanced_search
          find_advanced_search_configuration
          @advanced_search_results = ItemList::AdvancedSearchResult.new(
            :model => @saved_search,
            :page => params[:page]
          )
          render("show")
        end
      end
    else
      render("new")
    end
  rescue StandardError
    redirect_to(:action => :new)
  end

  def show
    find_advanced_search
    @advanced_search_results = ItemList::AdvancedSearchResult.new(
      :model => @saved_search,
      :page => params[:page]
    )
  rescue StandardError
    redirect_to(:action => :new)
  end

  protected

  def track
    # Log event only if item_type param is present to avoid duplicates
    track_event("catalog_front") if params[:item_type].present?
  end

  private

  def build_advanced_search
    type = catalog.item_types.where(:slug => params[:item_type]).first

    @advanced_search = scope.new do |model|
      model.item_type = type || catalog.item_types.sorted.first
      model.creator = current_user if current_user.authenticated?
    end
  end

  def find_advanced_search
    @saved_search = scope.where(:uuid => params[:uuid]).first
  end

  def advanced_search_params
    search = ItemList::AdvancedSearchResult.new(:model => @advanced_search)
    search.permit_criteria(params.require(:advanced_search))
  end

  def find_advanced_search_configuration
    @advanced_search_config = AdvancedSearchConfiguration.find_by(id: params[:advanced_search_conf])
  end

  def scope
    catalog.advanced_searches
  end
end
