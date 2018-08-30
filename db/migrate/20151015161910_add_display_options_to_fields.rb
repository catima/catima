class AddDisplayOptionsToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :primary, :boolean, :null => false, :default => false
    add_column :fields, :display_in_list, :boolean, :null => false, :default => true
  end
end
