class AddPositionToChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :choices, :position, :integer
  end
end
