class ItemList::FavoriteResult < ItemList
  def initialize(current_user:, selected_catalog:, page: nil, per: nil)
    super(nil, page, per)
    @current_user = current_user
    @selected_catalog = selected_catalog
  end

  def unpaginaged_items
    Item.where(id: favorites.map(&:id))
  end

  private

  def favorites
    favorite_items(Item).each_with_object([]) do |item, array|
      if @selected_catalog
        next unless item.catalog == @selected_catalog
      end
      array << item if @current_user.can_list_item?(item)
    end
  end

  def favorite_items(scope)
    scope.joins(:favorites).where('favorites.user_id' => @current_user)
  end
end
