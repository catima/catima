class AddJtiToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :jti, :string
    User.all.each do |user|
      user.update_column(:jti, SecureRandom.uuid)
    end
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end
end
