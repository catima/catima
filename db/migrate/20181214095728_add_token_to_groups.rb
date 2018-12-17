class AddTokenToGroups < ActiveRecord::Migration[5.2]
  def up
    add_column :groups, :token, :string, :null => true
  end

  def down
    remove_column :groups, :token
  end
end
