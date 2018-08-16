class AddRowOrderToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :row_order, :integer
  end
end
