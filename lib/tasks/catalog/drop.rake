namespace :catalog do
  desc "Drop a catalog"
  task :drop => [:environment] do
    (catalog = ENV['catalog']) || raise("ERROR. No catalog specified. \n\rUSAGE: rake catalog:dump catalog=<slug>")
    Catalog.find_by(slug: catalog).destroy
  end
end
