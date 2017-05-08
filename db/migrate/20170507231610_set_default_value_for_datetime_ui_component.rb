class SetDefaultValueForDatetimeUiComponent < ActiveRecord::Migration
  def up
    execute(<<~SQL)
      UPDATE fields
      SET ui_component = 'DateTimeInput'
      WHERE type = 'Field::DateTime'
    SQL
  end

  def down
  end
end
