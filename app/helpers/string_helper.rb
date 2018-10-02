module StringHelper
  def sentence_case(string)
    return if string.nil?

    string.gsub(/^\s*\S/, &:upcase)
  end
end
