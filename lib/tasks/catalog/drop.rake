namespace :catalog do
  desc "Drop a catalog"
  task :drop => [:environment] do
    (slug = ENV.fetch('catalog', nil)) || raise("ERROR. No catalog specified. \n\rUSAGE: rake catalog:drop catalog=<slug>")
    (c = Catalog.find_by(slug: slug)) || raise("ERROR. No catalog '#{slug}' found.")
    c.destroy
  end
end
