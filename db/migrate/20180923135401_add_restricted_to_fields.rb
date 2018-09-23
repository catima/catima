class AddRestrictedToFields < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :restricted, :boolean, null: false, default: false
  end
end
