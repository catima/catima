class AddInvitedByToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :invited_by_id, :integer, :index => true
    add_foreign_key "users", "users", :column => "invited_by_id"
  end
end
