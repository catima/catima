class ChangeDefaultValueForRequiredField < ActiveRecord::Migration[6.1]
  def up
    change_column_default :fields, :required, false
  end

  def down
    change_column_default :fields, :required, true
  end
end
