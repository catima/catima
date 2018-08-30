class DropPositionFromFields < ActiveRecord::Migration[4.2]
  def change
    remove_column :fields, :position, :integer, :null => false, :default => 0
  end
end
