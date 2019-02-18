# Abstract base class for all item list presenters. These presenters are
# responsible for generating links that allow a user to navigate from a list
# to an item in the list, and then back again. To accomplish this, certain
# parameters must be maintained in the URLs.
#
class ItemListPresenter
  attr_reader :view, :item, :offset, :list
  delegate :capture, :link_to, :item_path, :render, :to => :view
  delegate :item_type, :to => :item

  def initialize(view, item, offset, list)
    @view = view
    @item = item
    @offset = offset.to_i
    @list = list
  end

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
          :item_type_slug => item_type,
          :id => item,
          :uuid => list.search_uuid
        )
      ),
      options
    )
  end

  # Renders the item detail page navbar that shows "back to search results"
  # and prev/next links.
  def render_nav
    return if offset.blank?

    render(
      :partial => "items/item_list_nav",
      :locals => {
        :nav => nav,
        :item_list => list,
        :item_list_path => path
      }
    )
  end

  private

  # Subclasses should override to generate the path that points from the given
  # item back to the results page for this list.
  def path
    nil
  end

  # Subclasses should override to provide the name of the query parameter that
  # accompanies item detail links. This parameter holds the context so that
  # "back to search", "next", and "prev" links can be rendered on the detail
  # page.
  def context_param
    nil
  end

  def context_params
    return {} if context_param.nil?

    { context_param => list.to_param }
  end

  def nav
    return nil if offset.blank?

    @nav ||= ItemList::Navigation.new(
      :results => list.items,
      :offset => offset,
      :current => item
    )
  end
end
