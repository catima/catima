class MakePagesMultilingual < ActiveRecord::Migration
  def up
    remove_column :pages, :content
    rename_column :pages, :locale, :locale_old
    rename_column :pages, :title, :title_old
    add_column :pages, :title, :jsonb
    # TODO: migrate the data
  end

  def down
    add_column :pages, :content, :text
    rename_column :pages, :locale_old, :locale
    remove_column :pages, :title
    rename_column :pages, :title_old, :title
  end
end
