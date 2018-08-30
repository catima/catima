class MakePagesMultilingual < ActiveRecord::Migration[4.2]
  def up
    remove_column :pages, :content

    add_column :containers, :locale, :string
    Container.all.each do |c|
      c.update(locale: c.page.locale)
    end

    rename_column :pages, :locale, :locale_old
    rename_column :pages, :title, :title_old
    add_column :pages, :title, :jsonb
  end

  def down
    add_column :pages, :content, :text
    rename_column :pages, :locale_old, :locale
    remove_column :pages, :title
    rename_column :pages, :title_old, :title

    remove_column :containers, :locale, :string
  end
end
