namespace :catalog do
  desc "Dump a catalog to a directory"
  DUMP_USAGE = 'rake catalog:dump catalog=<slug> dir=<path>'.freeze
  task :dump => [:environment] do
    (catalog = ENV['catalog']) || raise("No catalog specified. \n\rUSAGE: #{DUMP_USAGE}")
    (directory = ENV['dir']) || raise("No output directory specified. \n\rUSAGE: #{DUMP_USAGE}")
    CatalogDump.new.dump(catalog, directory)
  end
end
