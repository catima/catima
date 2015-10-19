class AddUuidColumnToFields < ActiveRecord::Migration
  def change
    add_column :fields, :uuid, :string
  end
end
