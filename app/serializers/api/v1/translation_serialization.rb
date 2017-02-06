module API::V1::TranslationSerialization
  private

  def translation_hash(data)
    data&.transform_keys { |key| key[/_([^_]+)$/, 1] }
  end
end
