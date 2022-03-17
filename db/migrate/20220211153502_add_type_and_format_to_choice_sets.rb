class AddTypeAndFormatToChoiceSets < ActiveRecord::Migration[6.1]
  def change
    add_column :choice_sets, :choice_set_type, :integer
    add_column :choice_sets, :format, :string
  end
end
