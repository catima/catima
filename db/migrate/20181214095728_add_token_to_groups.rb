class AddTokenToGroups < ActiveRecord::Migration[5.2]
  def up
    add_column :groups, :identifier, :string, :null => true
  end

  def down
    remove_column :groups, :identifier
  end
end
