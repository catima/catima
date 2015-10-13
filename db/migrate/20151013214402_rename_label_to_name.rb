class RenameLabelToName < ActiveRecord::Migration
  def change
    rename_column :item_types, :label, :name
  end
end
