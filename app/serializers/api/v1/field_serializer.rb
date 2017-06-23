class API::V1::FieldSerializer < ActiveModel::Serializer
  include API::V1::TranslationSerialization

  attributes :uuid, :i18n, :multiple
  attribute(:label) { translation_hash(object.name_translations) }
  attribute(:type) { object.short_type_name }
end
