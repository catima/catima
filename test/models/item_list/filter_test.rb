require "test_helper"

class ItemList::FilterTest < ActiveSupport::TestCase
  test "finds nothing if field is non-browseable" do
    field = fields(:one_author_name)
    browse = ItemList::Filter.new(
      :item_type => field.item_type,
      :field => field,
      :value => "Stephen King"
    )
    assert_empty(browse.items.to_a)
  end

  test "finds everything if field is nil" do
    author = item_types(:one_author)
    browse = ItemList::Filter.new(:item_type => author)
    assert_equal(author.sorted_items.to_a, browse.items.to_a)
  end

  test "finds choice items" do
    author = author_with_english_choice
    author.save!

    language_field = fields(:one_author_language)
    browse = ItemList::Filter.new(
      :item_type => language_field.item_type,
      :field => language_field,
      :value => choices(:one_english).id.to_s
    )
    results = browse.items

    assert_equal(1, results.count)
    assert_includes(results.to_a, author)
  end

  test "only shows public items" do
    book = item_types(:reviewed_book)
    browse = ItemList::Filter.new(:item_type => book)

    results = browse.items.to_a
    assert_includes(results, items(:reviewed_book_finders_keepers_approved))
    refute_includes(results, items(:reviewed_book_end_of_watch))
  end

  private

  def author_with_english_choice
    author = items(:one_author_stephen_king)
    english = choices(:one_english)
    # Have to set this manually because fixture doesn't know ID ahead of time
    author.data["one_author_language_uuid"] = [english.id.to_s]
    author
  end
end
