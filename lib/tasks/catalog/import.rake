namespace :catalog do
  desc "Import catalog from JSON dump"
  USAGE = 'rake catalog:import jsonfile=<path>'
  task :import => [:environment] do |t, args|
    (jsonfile = ENV['jsonfile']) || raise("No input JSON file specified. \n\rUSAGE: #{USAGE}")
    CatalogImport.new.import(jsonfile)
  end
end
