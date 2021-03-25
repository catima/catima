class AddParentToChoices < ActiveRecord::Migration[6.1]
  def change
    add_reference :choices, :parent, index: true, foreign_key: {to_table: :choices}
  end
end
