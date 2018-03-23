class CatalogListOutput
  def self.msg(txt)
    puts txt unless Rails.env.test?
  end
end

namespace :catalog do
  desc "Lists all catalogs"
  task :list => [:environment] do
    Catalog.order(:slug).each { |c| CatalogListOutput.msg(c.slug) }
  end
end
