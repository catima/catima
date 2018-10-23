class Search::EditorStrategy < Search::BaseStrategy
  def keywords_for_index(item)
    updater_for_keywords(item)
  end

  private

  def updater_for_keywords(item)
    return if field.updater.to_i.zero?
    return unless raw_value(item)
    return updater_from_hash(raw_value(item)) if raw_value(item).is_a?(Hash)

    raw_value(item).flat_map { |image| [updater_from_hash(image)] }.compact
  end

  def updater_from_hash(hash)
    hash.key?("updater") ? hash.fetch("updater") : nil
  end
end
