class ItemList::SavedSearch < ItemList
  def initialize(user:, selected_catalog:, page: nil, per: nil)
    super(nil, page, per)
    @user = user
    @selected_catalog = selected_catalog
  end

  def unpaginaged_items
    ::Search.where(id: searches.map(&:id))
  end

  private

  def searches
    search_items(::Search).each_with_object([]) do |search, array|
      if @selected_catalog
        next unless search.catalog == @selected_catalog
      end

      array << search if @user.can_list_item?(search)
      array << search
    end
  end

  def search_items(scope)
    scope.where(:user_id => @user)
  end
end
