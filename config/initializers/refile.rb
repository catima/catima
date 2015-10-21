Refile.cache = Refile::Backend::FileSystem.new(Rails.root.join("tmp", "refile"))
Refile.store = Refile::Backend::FileSystem.new(
  Rails.root.join("public", "system", "refile")
)
