class ExternalType::Item
  def self.from_json(json)
    new(json["id"], json["name"])
  end

  attr_reader :id, :name_translations

  def initialize(id, name_translations)
    @id = id
    @name_translations = name_translations
  end

  def name(locale=I18n.locale)
    name_translations[locale.to_s]
  end
end
