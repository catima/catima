class DropPositionFromFields < ActiveRecord::Migration
  def change
    remove_column :fields, :position, :integer, :null => false, :default => 0
  end
end
