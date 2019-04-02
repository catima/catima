require "test_helper"

class Search::ChoiceSetStrategyTest < ActiveSupport::TestCase
  test "keywords_for_index" do
    author = author_with_english_choice
    language_field = fields(:one_author_language)
    strategy = Search::ChoiceSetStrategy.new(language_field, :en)
    assert_equal(%w(Eng English), strategy.keywords_for_index(author))
  end

  test "item can be found by choice" do
    author = author_with_english_choice
    author.save!

    language_field = fields(:one_author_language)
    strategy = Search::ChoiceSetStrategy.new(language_field, :en)

    criteria = { :any => [choices(:one_english).id.to_s] }
    results = strategy.search(Item, criteria)

    assert_equal(1, results.count)
    assert_includes(results.to_a, author)
  end

  test "multiple items can be found by choice" do
    author = author_with_english_and_spanish_choices
    author.save!

    language_field = fields(:one_author_other_languages)
    strategy = Search::ChoiceSetStrategy.new(language_field, :en)

    criteria = { :any => [choices(:one_english).id.to_s] }
    results = strategy.search(Item, criteria)

    assert_equal(2, results.count)
    assert_includes(results.to_a, author)
  end

  test "items can be browsed by choice" do
    author = author_with_english_choice
    author.save!

    language_field = fields(:one_author_language)
    strategy = Search::ChoiceSetStrategy.new(language_field, :en)

    results = strategy.browse(Item, "en-Eng")

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

  def author_with_english_and_spanish_choices
    author = items(:one_author_stephen_king)
    choices = [choices(:one_english), choices(:one_spanish)]
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_other_language_uuid"] = choices.map(&:id).map(&:to_s)
    author
  end
end
