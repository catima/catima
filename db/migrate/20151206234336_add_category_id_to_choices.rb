class AddCategoryIdToChoices < ActiveRecord::Migration[4.2]
  def change
    add_reference :choices, :category, index: true, foreign_key: true
  end
end
