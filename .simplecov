require "simplecov"
SimpleCov.start("rails") do
  add_filter("/bin/")
  add_filter("/lib/tasks/assets.rake")
  add_filter("/lib/tasks/auto_annotate_models.rake")
  add_filter("/lib/tasks/coverage.rake")
end
SimpleCov.use_merging(false)
