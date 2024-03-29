class CatalogCloner
  include ActiveModel::Model
  include HasSlug

  # this method is overrides HasSlug because validates_uniqueness_of is not present in Class Object
  def self.validates_uniqueness_of(*args)
  end

  validates_slug
  validate :validates_uniqueness_of_slug

  attr_accessor :catalog, :slug

  def initialize(catalog, slug: nil)
    @catalog = catalog
    @slug = slug || @catalog.slug
  end

  def call
    return unless valid?

    catalog.clone!(slug: slug)
    self
  end

  def validates_uniqueness_of_slug
    errors.add(:slug, :taken) if Catalog.exists?(slug: slug)
  end
end
