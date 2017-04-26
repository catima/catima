# Extends DataStore to add support for ActiveModel::Dirty. This allows
# ActiveRecord to know when the data hash has changed and the item needs
# to be saved to the database.
class DataStore::DirtyAwareStore < DataStore
  attr_reader :item

  def initialize(item:, key:, multivalued:, locale:, transformer: nil)
    @item = item
    super(
      :data => item.data,
      :key => key,
      :multivalued => multivalued,
      :locale => locale,
      :transformer => transformer
    )
  end

  def set(value)
    item.data_will_change!
    super
  end
end
