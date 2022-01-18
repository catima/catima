class AddTimelineFieldsToContainer < ActiveRecord::Migration[6.1]
  def change
    add_column :containers, :filterable_field_id, :integer, index: true
    add_column :containers, :field_format, :string
    add_column :containers, :sort, :string
  end
end
