Refile.cache = Refile::Backend::FileSystem.new(Rails.root.join("tmp", "refile"))
Refile.store = Refile::Backend::FileSystem.new(
  Rails.public_path.join("system", "refile")
)
