class ItemList::FavoriteResult < ItemList
  def initialize(current_user:, page: nil, per: nil)
    super(nil, page, per)
    @current_user = current_user
  end

  def unpaginaged_items
    Item.where(id: favorites.map(&:id))
  end

  private

  def favorites
    favorite_items(Item).each_with_object([]) do |item, array|
      array << item if item.catalog.public_items.exists?(item.id) && @current_user.catalog_visible_for_role?(item.catalog)
    end
  end

  def favorite_items(scope)
    scope.joins(:favorites).where('favorites.user_id' => @current_user)
  end
end
