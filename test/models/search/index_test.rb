require "test_helper"

class Search::IndexTest < ActiveSupport::TestCase
  test "concatenates multiple keywords" do
    author = items(:one_author_stephen_king)
    data = Search::Index.new(:item => author, :locale => :en).data
    assert_instance_of(String, data)
    assert_match(/Stephen King/, data)
    assert_match(/Steve/, data)
  end
end
