require "test_helper"

class Search::MacrosTest < ActiveSupport::TestCase
  test "reindex populates search_data columns" do
    author = items(:one_author_stephen_king)

    refute_match(/Stephen King/, author.search_data_de)
    refute_match(/Stephen King/, author.search_data_en)
    refute_match(/Stephen King/, author.search_data_fr)
    refute_match(/Stephen King/, author.search_data_it)

    Item.reindex
    author.reload

    assert_match(/Stephen King/, author.search_data_de)
    assert_match(/Stephen King/, author.search_data_en)
    assert_match(/Stephen King/, author.search_data_fr)
    assert_match(/Stephen King/, author.search_data_it)
  end

  test "indexes on save" do
    author = items(:one_author_stephen_king)
    refute_match(/changed/, author.search_data_en)

    author.behaving_as_type.public_send("one_author_name_uuid=", "changed")
    author.save!

    assert_match(/changed/, author.search_data_en)
  end

  test "simple_search" do
    Item.reindex
    results = catalogs(:one).items.simple_search("king")
    assert_includes(results, items(:one_author_stephen_king))
  end

  test "simple_search honors scope" do
    Item.reindex
    results = catalogs(:two).items.simple_search("king")
    refute_includes(results, items(:one_author_stephen_king))
  end
end
