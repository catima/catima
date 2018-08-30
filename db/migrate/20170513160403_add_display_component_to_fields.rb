class AddDisplayComponentToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :display_component, :string
  end
end
