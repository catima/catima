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
end
