class AddSlugToChoiceSets < ActiveRecord::Migration[4.2]
  def change
    add_column :choice_sets, :slug, :string
  end
end
