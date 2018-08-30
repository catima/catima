class PopulateFieldSetType < ActiveRecord::Migration[4.2]
  def change
    execute("UPDATE fields SET field_set_type = 'ItemType'")
  end
end
