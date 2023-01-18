class AddJtiToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :jti, :string
    User.with_deleted.all.each do |user|
      # rubocop:disable Rails/SkipsModelValidations
      user.update_column(:jti, SecureRandom.uuid)
      # rubocop:enable Rails/SkipsModelValidations
    end
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end
end
