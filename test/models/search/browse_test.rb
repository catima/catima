require "test_helper"

class Search::BrowseTest < ActiveSupport::TestCase
  test "finds nothing if field is non-browseable" do
    field = fields(:one_author_name)
    browse = Search::Browse.new(:field => field, :value => "Stephen King")
    assert_empty(browse.items.to_a)
  end

  test "finds choice items" do
    author = author_with_english_choice
    author.save!

    language_field = fields(:one_author_language)
    browse = Search::Browse.new(:field => language_field, :value => "en-Eng")
    results = browse.items

    assert_equal(1, results.count)
    assert_includes(results.to_a, author)
  end

  private

  def author_with_english_choice
    author = items(:one_author_stephen_king)
    english = choices(:one_english)
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = english.id
    author
  end
end
