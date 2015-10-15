class AddRowOrderToFields < ActiveRecord::Migration
  def change
    add_column :fields, :row_order, :integer
  end
end
