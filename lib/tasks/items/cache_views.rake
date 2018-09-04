class ItemsCacheViewsOutput
  def self.msg(txt)
    puts txt unless Rails.env.test?
  end

  def self.print_usage
    puts 'rake items:cache_views catalog=<slug> item_type=<slug> item=<id>'
  end
end

namespace :items do
  desc "Cache views for items"
  task :cache_views => [:environment] do
    catalog = ENV['catalog']
    itemtype = ENV['item_type']
    item_id = ENV['item']
    if catalog.nil?
      ItemsCacheViewsOutput.msg 'Caching views for all item types in all catalogs.'
      ItemsCacheViewsOutput.msg 'You can restrict the catalog and specify an item type with:'
      ItemsCacheViewsOutput.print_usage
    end
    ItemsCacheWorker.new.perform(catalog, itemtype, item_id)
  end
end
