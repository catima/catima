class PopulateFieldSetType < ActiveRecord::Migration
  def change
    execute("UPDATE fields SET field_set_type = 'ItemType'")
  end
end
