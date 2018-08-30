class ChangeItemDataFieldToJsonb < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.connection.execute(
      "ALTER TABLE items ALTER COLUMN data
       SET DATA TYPE jsonb USING data::jsonb"
    )
  end

  def down
    ActiveRecord::Base.connection.execute(
      "ALTER TABLE items ALTER COLUMN data
       SET DATA TYPE json USING data::json"
    )
  end
end
