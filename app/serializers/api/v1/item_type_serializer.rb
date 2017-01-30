class API::V1::ItemTypeSerializer < ActiveModel::Serializer
  attributes :id, :slug
  attribute(:name) { translation_hash(object.name_translations) }
  attribute(:name_plural) { translation_hash(object.name_plural_translations) }

  private

  def translation_hash(data)
    data.transform_keys { |key| key[/_([^_]+)$/, 1] }
  end
end
