class AddAllowBcToChoiceSets < ActiveRecord::Migration[6.1]
  def change
    add_column :choice_sets, :allow_bc, :boolean, default: false
  end
end
