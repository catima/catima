class AddCatalogToChoices < ActiveRecord::Migration
  def change
    add_reference :choices, :catalog, index: true, foreign_key: true
  end
end
