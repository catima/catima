class API::V3::Catalog::SimpleSearchesController < API::V3::Catalog::BaseController
  def show
    paginate
    authorize(@catalog, :simple_search_show?) unless authenticated_catalog?

    find_simple_search
    return routing_error if @simple_search.nil?

    @simple_search_results = ItemList::SimpleSearchResult.new(
      :catalog => @catalog,
      :query => @simple_search.query,
      :page => params[:page],
      :item_type_slug => params[:item_type_slug],
      :search_uuid => @simple_search.uuid
    )
  end

  def create
    paginate
    authorize(@catalog, :simple_search_create?) unless authenticated_catalog?

    build_simple_search
    if @simple_search.update(simple_search_params)
      @simple_search_results = ItemList::SimpleSearchResult.new(
        :catalog => @catalog,
        :query => @simple_search.query,
        :page => params[:page],
        :item_type_slug => params[:item_type_slug],
        :search_uuid => @simple_search.uuid
      )
      render("api/v3/catalog/simple_searches/show")
    else
      render_unprocessable_record(@simple_search)
    end
  end

  private

  def paginate
    @page = params[:page]
    @per = params[:per]
  end

  def build_simple_search
    @simple_search = scope.new do |simple_search|
      simple_search.creator = @current_user if !authenticated_catalog? && @current_user.authenticated?
    end
  end

  def find_simple_search
    @simple_search = SimpleSearch.find_by(:uuid => params[:uuid])
  end

  def simple_search_params
    params.permit(:q)
  end

  def scope
    @catalog.simple_searches
  end
end
