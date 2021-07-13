class CreateAPILogs < ActiveRecord::Migration[6.1]
  def change
    create_table :api_logs do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :catalog
      t.string :endpoint
      t.string :remote_ip
      t.json :payload
      t.timestamps
    end
  end
end
