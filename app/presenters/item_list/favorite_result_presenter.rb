class ItemList::FavoriteResultPresenter < ItemListPresenter
  # Generates a link to the detail page with enough context in the query params
  # so that position in the search result, etc. is maintained.
  def item_link(*args, &block)
    options = args.extract_options!
    context = context_params
    context[:offset] = list.offset + offset if context.present?

    link_to(
      block ? capture(&block) : args.first,
      item_path(
        context.merge(
          :catalog_slug => item.catalog.slug,
          :locale => I18n.locale,
          :item_type_slug => item_type,
          :id => item
        )
      ),
      options
    )
  end
end
