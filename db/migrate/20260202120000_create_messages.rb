class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.text :text, null: false
      t.string :severity, default: 'info', null: false
      t.string :scope, default: 'admin', null: false
      t.boolean :active, default: false, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.references :catalog, foreign_key: { on_delete: :cascade }, index: true

      t.timestamps
    end

    add_index :messages, [:active, :scope, :catalog_id, :starts_at, :ends_at],
              name: 'index_messages_on_active_scope_catalog_dates'
  end
end
