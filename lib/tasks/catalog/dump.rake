class CatalogDumpOutput
  def self.msg(txt)
    puts txt unless Rails.env.test?
  end

  def self.print_usage
    puts 'rake catalog:dump catalog=<slug> dir=<path>'
  end
end

namespace :catalog do
  desc "Dump a catalog to a directory"
  task :dump => [:environment] do
    catalog = ENV['catalog']
    directory = ENV['dir']
    if catalog.nil? || directory.nil?
      CatalogDumpOutput.print_usage
    else
      CatalogDump.new.dump(catalog, directory)
      CatalogDumpOutput.msg "Catalog #{catalog} dumped to #{directory}."
    end
  end
end
