class CatalogLoadOutput
  def self.msg(txt)
    puts txt
  end

  def self.print_usage
    puts 'rake catalog:load dir=<dump-directory> slug=<new-slug>'
  end
end

namespace :catalog do
  desc "Load catalog from dump directory"
  task :load => [:environment] do
    directory = ENV['dir']
    new_slug = ENV['slug']
    if directory.nil?
      CatalogLoadOutput.msg 'No dump directory specified.'
      CatalogLoadOutput.print_usage
    else
      CatalogLoad.new(directory, new_slug).load
      CatalogLoadOutput.msg "Catalog #{new_slug} loaded."
    end
  end
end
