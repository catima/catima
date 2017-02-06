class API::V1::ItemTypeSerializer < ActiveModel::Serializer
  include API::V1::TranslationSerialization

  attributes :id, :slug
  attribute(:name) { translation_hash(object.name_translations) }
  attribute(:name_plural) { translation_hash(object.name_plural_translations) }
end
