class AddDefaultValueToChoiceSetType < ActiveRecord::Migration[6.1]
  def change
    change_column_default(
      :choice_sets,
      :choice_set_type,
      from: nil,
      to: 0
    )

    ChoiceSet.update_all(:choice_set_type => 0)
  end
end
