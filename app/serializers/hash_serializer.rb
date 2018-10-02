class HashSerializer
  def self.dump(val)
    val.is_a?(Hash) ? val : JSON.parse(val)
  end

  def self.load(hash)
    return '{}' if hash.nil?

    hash.empty? ? '{}' : JSON.dump(hash)
  end
end
