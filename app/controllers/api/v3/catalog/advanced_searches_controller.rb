class API::V3::Catalog::AdvancedSearchesController < API::V3::Catalog::BaseController
  include AdvancedSearchesHelper

  def new
    authorize(@catalog, :advanced_search_new?) unless authenticated_catalog?

    @advance_search_confs = @catalog.advanced_search_configurations.with_active_item_type
    build_advanced_search
    find_advanced_search_configuration

    if @advanced_search_config.present?
      @item_types = @advanced_search_config.item_types
      @fields = @advanced_search_config.field_set

      # Initial display of map
      if @advanced_search_config.search_type_map?
        params[:item_type_id] = @advanced_search_config.item_type.z
        build_advanced_search
        @search = ItemList::AdvancedSearchResult.new(
          model: @advanced_search
        )
      end
    else
      @item_types = @advanced_search.item_types.order(:slug => :asc)

      if @item_types.blank?
        # If no item_type is available, redirect to catalog homepage with a warning
        return redirect_to catalog_home_path, :alert => t('errors.messages.advanced_searches.not_available')
      end

      @fields = @advanced_search.fields

      return redirect_to action: :new, item_type: @item_types.first if params[:item_type_id].blank?
    end
  end

  def create
    authorize(@catalog, :advanced_search_create?) unless authenticated_catalog?

    build_advanced_search
    return unless @advanced_search.update(advanced_search_params)

    @saved_search = scope.where(uuid: @advanced_search.uuid).first
    @advanced_search_results = ItemList::AdvancedSearchResult.new(
      model: @saved_search,
      page: params[:page]
    )
    render("show")
  end

  def show
    authorize(@catalog, :advanced_search_show?) unless authenticated_catalog?

    find_advanced_search
    @advanced_search_results = ItemList::AdvancedSearchResult.new(
      model: @saved_search,
      page: params[:page]
    )
  rescue StandardError
    redirect_to(action: :new)
  end

  private

  def build_advanced_search
    type = @catalog.item_types.find(params[:item_type_id])
    @advanced_search = scope.new do |model|
      model.item_type = type || @catalog.item_types.sorted.first
      model.creator = current_user if !authenticated_catalog? && current_user.authenticated?
    end
  end

  def find_advanced_search
    @saved_search = scope.where(uuid: params[:uuid]).first
  end

  def advanced_search_params
    search = ItemList::AdvancedSearchResult.new(:model => @advanced_search)
    search.permit_criteria(ActionController::Parameters.new(formatted_api_params(params.require(:advanced_search))))
  end

  def find_advanced_search_configuration
    @advanced_search_config = AdvancedSearchConfiguration.find_by(id: params[:advanced_search_conf])
  end

  def scope
    @catalog.advanced_searches
  end
end
