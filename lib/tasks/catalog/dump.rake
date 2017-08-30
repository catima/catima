namespace :catalog do
  desc "Dump a catalog to a directory"
  DUMP_USAGE = 'rake catalog:dump catalog=<slug> dir=<path>'
  task :dump => [:environment] do |t, args|
    (catalog = ENV['catalog']) || raise("No catalog specified. \n\rUSAGE: #{DUMP_USAGE}")
    (directory = ENV['dir']) || raise("No output directory specified. \n\rUSAGE: #{DUMP_USAGE}")
    CatalogDump.new.dump(catalog, directory)
  end
end
