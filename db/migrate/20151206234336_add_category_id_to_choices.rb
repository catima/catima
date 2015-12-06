class AddCategoryIdToChoices < ActiveRecord::Migration
  def change
    add_reference :choices, :category, index: true, foreign_key: true
  end
end
