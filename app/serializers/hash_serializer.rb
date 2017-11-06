class HashSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    (hash || {})
  end
end
