class RenameLabelToName < ActiveRecord::Migration[4.2]
  def change
    rename_column :item_types, :label, :name
  end
end
