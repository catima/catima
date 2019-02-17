# == Schema Information
#
# Table name: searches
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  item_id    :integer
#  updated_at :datetime         not null
#  user_id    :integer
#

module SearchesHelper
  def search_exists_for_user?(search)
    ::Search.exists?(:related_search => search, :user => current_user)
  end

  def empty_searches_warning(selected_catalog)
    selected_catalog ? t("searches.list.empty_for_catalog") : t("searches.list.empty")
  end

  def search_name(search)
    l(search.created_at)
  end

  def item_list_display_types(f)
    f.select(
      :display_type,
      ItemList::STYLES.map { |style, _| [style, style] },
      :label => t(".display_type.label"),
      :help => t(".display_type.help"),
      :include_blank => true
    )
  end

  def user_searches(form, user)
    searches = ::Search.where(:user => user)
    form.collection_select(
      :search,
      searches,
      :uuid,
      :search_name,
      :label => t(".search.label"),
      :help => t(".search.help")
    )
  end
end
