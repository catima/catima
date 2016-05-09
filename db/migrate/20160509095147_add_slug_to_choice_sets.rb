class AddSlugToChoiceSets < ActiveRecord::Migration
  def change
    add_column :choice_sets, :slug, :string
  end
end
