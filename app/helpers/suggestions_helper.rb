module SuggestionsHelper
  def display_suggestion_form?(item_type)
    return false unless item_type.suggestions_activated?

    return false unless current_user.authenticated? || item_type.allow_anonymous_suggestions?

    true
  end

  def display_suggestions?(item, item_type)
    return false unless item_type.suggestions_activated?

    return false unless item.present? && item.suggestions.any?

    true
  end

  def item_suggestion_badge?(item, item_type)
    item_type.suggestions_activated? && item_has_suggestions?(item)
  end

  def item_has_suggestions?(item)
    item.suggestions.where(:processed_at => nil).any?
  end

  def item_suggestions_count(item)
    item.suggestions.where(:processed_at => nil).count
  end

  def catalog_suggestions(catalog)
    catalog.suggestions.where(
      :item_type => ItemType.where(
        suggestions_activated: true
      )
    ).ordered
  end
end
