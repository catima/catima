require "test_helper"

class Search::ChoiceSetStrategyTest < ActiveSupport::TestCase
  test "keywords_for_index" do
    author = items(:one_author_stephen_king)
    english = choices(:one_english)
    language_field = fields(:one_author_language)
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = english.id

    strategy = Search::ChoiceSetStrategy.new(language_field, :en)
    assert_equal(%w(Eng English), strategy.keywords_for_index(author))
  end
end
