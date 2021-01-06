module NavbarHelper
  # Generate <li><a href=...></a></li> appropriate for the Bootstrap navbar.
  # If :active_when hash is provided in the options, a class=active will
  # automatically be added to the <li> when appropriate.
  #
  # Example:
  #
  #     <%= navbar_link_to(
  #           "Home",
  #           root_path,
  #           :active_when => { :controller => "home" }) %>
  #
  def navbar_link_to(label, path, options={})
    active_when = options.delete(:active_when) { Hash.new }
    active = active_when.all? do |key, value|
      value === params[key].to_s
    end

    tag.li(:class => ["nav-item", ("active" if active)]) do
      link_to(label, path, options.merge(class: "nav-link"))
    end
  end

  def menu_item_active?(menu_item, submenus: nil)
    slug = params[:item_type_slug] || params[:slug]
    if (item_type = menu_item.item_type)
      slug == item_type.slug
    elsif menu_item.page
      slug == menu_item.page.slug
    elsif submenus
      submenus.any? { |sub| menu_item_active?(sub) }
    end
  end
end
