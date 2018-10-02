class Search::ReferenceStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch

  def keywords_for_index(item)
    primary_text_for_keywords(item)
  end

  def browse(scope, item_id)
    search_data_matching_one_or_more(scope, item_id)
  end

  private

  def primary_text_for_keywords(item)
    ids = raw_value(item)
    return if ids.blank?

    ids = [ids] unless ids.is_a?(Array)
    ids.each_with_object([]) do |key, array|
      item = Item.find_by(id: key)
      array << item.default_display_name(locale) if item
    end
  end
end
