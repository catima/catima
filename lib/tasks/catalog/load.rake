namespace :catalog do
  desc "Load catalog from dump directory"
  LOAD_USAGE = 'rake catalog:load dir=<dump-directory> slug=<new-slug>'
  task :load => [:environment] do 
    (directory = ENV['dir']) || raise("No dump directory specified. \n\rUSAGE: #{LOAD_USAGE}")
    new_slug = ENV['slug']
    CatalogLoad.new(directory, new_slug).load
  end
end