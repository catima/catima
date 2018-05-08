class ItemList::FavoriteResult < ItemList
  def initialize(current_user:, page: nil, per: nil)
    super(nil, page, per)
    @current_user = current_user
  end

  def unpaginaged_items
    favorites
  end

  private

  def favorites
    catalog_visible(
      public_items(
        favorite_items(
          Item
        )
      )
    )
  end

  def favorite_items(scope)
    scope.joins(:favorites).where('favorites.user_id' => @current_user)
  end

  def public_items(scope)
    return scope if approved_user?
    scope.where(:review_status => "approved")
  end

  def catalog_visible(scope)
    return scope if approved_user?
    scope.joins(:catalog).where(catalogs: { visible: true })
  end

  def approved_user?
    @current_user.system_admin
  end
end
