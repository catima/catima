class CreateLogEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :log_entries do |t|
      t.references :catalog, null: false
      t.references :subject, null: false, polymorphic: true
      t.references :author, null: false, foreign_key: {to_table: "users"}
      t.string :action, null: false
      t.jsonb :record_changes, default: {}

      t.timestamps
    end
  end
end
