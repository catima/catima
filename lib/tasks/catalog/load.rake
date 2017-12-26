namespace :catalog do
  desc "Load catalog from dump directory"
  LOAD_USAGE = 'rake catalog:load dir=<dump-directory> slug=<new-slug>'.freeze
  task :load => [:environment] do
    directory = ENV['dir']
    new_slug = ENV['slug']
    if directory.nil?
      puts "No dump directory specified.\n\rUSAGE: #{LOAD_USAGE}"
    else
      CatalogLoad.new(directory, new_slug).load
    end
  end
end
