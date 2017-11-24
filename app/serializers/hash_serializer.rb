class HashSerializer
  def self.dump(str)
    JSON.parse str
  end

  def self.load(hash)
    return '{}' if hash.nil?
    hash.empty? ? '{}' : JSON.dump(hash)
  end
end
