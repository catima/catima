class AddFromDateAndToDateToChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :choices, :from_date, :string
    add_column :choices, :to_date, :string
  end
end
