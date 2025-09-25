# == Schema Information
#
# Table name: advanced_searches
#
#  catalog_id                       :integer
#  created_at                       :datetime         not null
#  creator_id                       :integer
#  criteria                         :json
#  id                               :integer          not null, primary key
#  item_type_id                     :integer
#  locale                           :string           default("en"), not null
#  updated_at                       :datetime         not null
#  uuid                             :string
#  advanced_search_configuration_id :bigint
#

class AdvancedSearchesController < ApplicationController
  include ControlsCatalog

  def show
    @saved_search = fetch_saved_search
    @advanced_search_results = ItemList::AdvancedSearchResult.new(
      :model => @saved_search,
      :page => params[:page]
    )
  rescue StandardError
    redirect_to(:action => :new)
  end

  def new
    @advance_search_confs = @catalog.advanced_search_configurations.with_active_item_type

    @saved_search = fetch_saved_search
    @advanced_search_config = fetch_advanced_search_config(@saved_search)
    @advanced_search = build_advanced_search(@saved_search, @advanced_search_config)

    if @advanced_search_config.present?
      @item_types = @advanced_search_config.item_types
      @fields = @advanced_search_config.field_set

      # Initial display of map
      if @advanced_search_config.search_type_map?
        params[:item_type] = @advanced_search_config.item_type.slug
        @advanced_search = build_advanced_search(@saved_search, @advanced_search_config)
        @search = ItemList::AdvancedSearchResult.new(:model => @advanced_search)
      end
    else
      @item_types = @advanced_search.item_types.order(:slug => :asc)

      if @item_types.blank?
        # If no item_type is available, redirect to catalog homepage with a warning
        return redirect_to catalog_home_path, :alert => t('errors.messages.advanced_searches.not_available')
      end

      @fields = @advanced_search.fields
      @item_type_slug = @saved_search.item_type.slug if @saved_search&.item_type.present?
      @item_type_slug = params[:item_type] if params[:item_type].present?

      redirect_to :action => :new, :item_type => @item_types.first if @item_type_slug.nil?
    end
  end

  def create
    @saved_search = fetch_saved_search
    @advanced_search_config = fetch_advanced_search_config(@saved_search)
    @advanced_search = build_advanced_search(@saved_search, @advanced_search_config)

    if @advanced_search.update(advanced_search_params)
      respond_to do |f|
        f.html { redirect_to(:action => :show, :uuid => @advanced_search) }
        f.js do
          params[:uuid] = @advanced_search.uuid
          @saved_search = fetch_saved_search
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

  protected

  def track
    # Log event only if item_type param is present to avoid duplicates
    track_event("catalog_front") if params[:item_type].present?
  end

  private

  def fetch_saved_search
    scope.find_by(:uuid => params[:uuid])
  end

  def fetch_advanced_search_config(saved_search)
    return saved_search.advanced_search_configuration if saved_search&.advanced_search_configuration.present?

    AdvancedSearchConfiguration.find_by(id: params[:advanced_search_conf])
  end

  def build_advanced_search(saved_search, advanced_search_config)
    # Priority: explicit param > saved_search.item_type > first sorted
    chosen_type = if params[:item_type].present?
                    catalog.item_types.find_by(:slug => params[:item_type])
                  elsif saved_search&.item_type.present?
                    saved_search.item_type
                  end

    scope.new do |model|
      model.item_type = chosen_type || catalog.item_types.sorted.first
      model.creator = current_user if current_user.authenticated?
      model.advanced_search_configuration = advanced_search_config if advanced_search_config.present?
    end
  end

  def advanced_search_params
    search = ItemList::AdvancedSearchResult.new(:model => @advanced_search)
    search.permit_criteria(params.require(:advanced_search))
  end

  def scope
    catalog.advanced_searches
  end
end
