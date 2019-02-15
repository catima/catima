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
  def exists_for_user?(search)
    ::Search.exists?(:related_search => search, :user => current_user)
  end

  def empty_searches_warning(selected_catalog)
    selected_catalog ? t("searches.list.empty_for_catalog") : t("searches.list.empty")
  end
end
