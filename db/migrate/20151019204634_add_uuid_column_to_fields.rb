class AddUuidColumnToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :uuid, :string
  end
end
