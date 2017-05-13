# Provides a method for loading a JSON file in the `config` directory. Each
# catalog can override the default file by placing its on in
# `catalogs/<slug>/config`.
#
# Example:
#
#   JsonConfig.for_catalog(catalog).load("fields.json")
#
# In non-development environments the resulting JSON data will be cached until
# the server is restarted.
#
# TODO: test
class JsonConfig
  module Cache
    def self.store
      return {} if Rails.env.development?
      @_store ||= {}
    end

    def load(name)
      JsonConfig::Cache.store.fetch([*roots, name].join("-")) do
        super
      end
    end
  end

  prepend Cache

  def self.default
    for_catalog(nil)
  end

  def self.for_catalog(catalog)
    roots = [Rails.root.join("config")]
    roots.unshift(catalog.customization_root.join("config")) if catalog
    new(roots)
  end

  def initialize(roots)
    @roots = roots
  end

  def load(name)
    JSON.parse(IO.read(find_file(name)))
  end

  private

  attr_reader :roots

  def find_file(name)
    paths = roots.map { |r| r.join(name) }
    default_file = -> { paths.last }
    paths.find(default_file, &File.method(:file?))
  end
end
