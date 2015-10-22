# Extends DataStore to add support for ActiveModel::Dirty. This allows
# ActiveRecord to know when the data hash has changed and the item needs
# to be saved to the database.
class Item::DirtyAwareDataStore < Item::DataStore
  attr_reader :item

  def initialize(item:, key:, multivalued:, locale:)
    @item = item
    super(
      :data => item.data,
      :key => key,
      :multivalued => multivalued,
      :locale => locale
    )
  end

  def set(value)
    item.data_will_change!
    super
  end
end
