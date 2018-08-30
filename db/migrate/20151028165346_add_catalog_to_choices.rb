class AddCatalogToChoices < ActiveRecord::Migration[4.2]
  def change
    add_reference :choices, :catalog, index: true, foreign_key: true
  end
end
