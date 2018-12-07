class RemoveViewsValuesToItems < ActiveRecord::Migration[5.2]
  def change
    # Remove all cached data from items
    # rubocop:disable SkipsModelValidations
    Item.update_all(:views => nil)
    # rubocop:enable SkipsModelValidations
  end
end
