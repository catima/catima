class ObjetslittSimpleSearchesController < SimpleSearchesController
  def show
    super

    # Override the search result list to make the "textes" tab appear first
    # by default on a search without a type parameter, unless there is no text
    # in the results.

    # Reorder the result tabs based on this custom ordered list
    @preferred_type_slugs = %w[textes objets extraits textcrit auteur]
    set_active_tab
    reorder_tabs
  end

  private

  def set_active_tab
    # Make the "textes" tab active if available
    preferred_default_slug = @preferred_type_slugs[0]

    # Prevent making the "textes" tab active if it contains no results !
    # Otherwise it would hide occurrences when the search results contain no
    # "textes" but do contain items from other categories.
    preferred_type_count = @simple_search_results.item_counts_by_type.find do |type, _|
      type.slug == preferred_default_slug
    end&.last || 0

    # Override the active? method of the search results
    @simple_search_results.define_singleton_method(:active?) do |item_type|
      if item_type_slug.present? || preferred_type_count == 0
        # If a type slug is provided or there is no "textes", revert to default
        # display logic.
        super(item_type)
      else
        # Make the default result tab "textes" when there is at least one text
        item_type.slug == preferred_default_slug
      end
    end
  end

  def reorder_tabs
    # Reorder the categories based on the preferred_type_slugs list.
    @preferred_types = []
    found_types = {}

    # 1. Get the item counts by type into a dictionary
    @simple_search_results.item_counts_by_type do |type, count|
      found_types[type.slug] = [type, count]
    end

    # 2. Add the item counts by type to the preferred_types list in the order
    # of preferred_type_slugs
    @preferred_type_slugs.each do |type_slug|
      if found_types.key?(type_slug)
        type, count = found_types[type_slug]
        @preferred_types << [type, count]
      end
    end

    # 3. Add any remaining types that might not be in the preferred_type_slugs
    # list.
    found_types.each do |slug, (type, count)|
      next if @preferred_type_slugs.include?(slug)

      @preferred_types << [type, count]
    end
  end
end
