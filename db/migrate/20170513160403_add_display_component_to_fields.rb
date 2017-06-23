class AddDisplayComponentToFields < ActiveRecord::Migration
  def change
    add_column :fields, :display_component, :string
  end
end
