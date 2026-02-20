class ViatimagesSimpleSearchesController < SimpleSearchesController
  include AdvancedSearchConfig

  def show
    super

    # If no item type is specified, we want to show the first available item type
    # that has results. We want to restrict the search context to the images or corpus
    # item types. We will loop through the item types and break when we find
    # the first item type.
    #
    # We do all of this because we don't want to show any other item types in the
    # search results, and we want to show the images tab first if available.
    unless params[:type]
      @simple_search_results.item_counts_by_type.sort_by { |type, _| type.slug == 'images' ? 0 : 1 }.each do |type, count|
        item_type_slug = type.slug == 'images' || type.slug == 'corpus' ? type.slug : 'cannotwork'
        @simple_search_results = ItemList::SimpleSearchResult.new(
          catalog: catalog,
          query: @saved_search.query,
          page: params[:page],
          item_type_slug: item_type_slug,
          search_uuid: @saved_search.uuid
        )
        break
      end
    end

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param
  end
end
