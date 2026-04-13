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

  test "finds items by category choice set field" do
    # Test that filtering by a ChoiceSet field inside a category works
    vehicle_type = item_types(:nested_vehicle)
    color_field = vehicle_type.all_fields.find { |f| f.slug == 'color' }
    red_choice = choices(:nested_car_color_red)

    browse = ItemList::Filter.new(
      :item_type => vehicle_type,
      :field => color_field,
      :value => red_choice.id.to_s
    )
    results = browse.items

    assert_equal(2, results.count)
    assert_includes(results.to_a, items(:nested_vehicle_red_car))
    assert_includes(results.to_a, items(:nested_vehicle_another_red_car))
    refute_includes(results.to_a, items(:nested_vehicle_blue_car))
    refute_includes(results.to_a, items(:nested_vehicle_bicycle))
  end

  test "finds items by category complex datation field" do
    # Test that filtering by a ComplexDatation field inside a category works
    vehicle_type = item_types(:nested_vehicle)
    manufacture_date_field = vehicle_type.all_fields.find { |f| f.slug == 'manufacture-date' }
    year_2020 = choices(:nested_car_year_2020)

    browse = ItemList::Filter.new(
      :item_type => vehicle_type,
      :field => manufacture_date_field,
      :value => year_2020.id.to_s
    )
    results = browse.items

    assert_equal(2, results.count)
    assert_includes(results.to_a, items(:nested_vehicle_red_car))
    assert_includes(results.to_a, items(:nested_vehicle_another_red_car))
    refute_includes(results.to_a, items(:nested_vehicle_blue_car))
    refute_includes(results.to_a, items(:nested_vehicle_bicycle))
  end

  test "strategy matches by uuid not object identity" do
    # Test that the strategy lookup works even when field instances differ
    vehicle_type = item_types(:nested_vehicle)
    color_field = vehicle_type.all_fields.find { |f| f.slug == 'color' }
    red_choice = choices(:nested_car_color_red)

    browse = ItemList::Filter.new(
      :item_type => vehicle_type,
      :field => color_field,
      :value => red_choice.id.to_s
    )

    # The strategy should be found even though all_fields creates new field instances
    assert_not_nil(browse.send(:strategy))
    assert_equal(color_field.uuid, browse.send(:strategy).field.uuid)
  end

  test "sorts search_vehicle items by int field (doors) ascending — numeric not lexicographic" do
    doors_field = fields(:search_vehicle_doors)
    browse = ItemList::Filter.new(
      :item_type => item_types(:search_vehicle),
      :sort_field => doors_field,
      :sort => "ASC"
    )
    results = browse.items.to_a

    # Motorcycle (0 doors) must be first; bus (11 doors) must be last.
    assert_equal items(:search_vehicle_motorcycle), results.first
    assert_equal items(:search_vehicle_bus),        results.last

    # In lexicographic order "11" < "3", so bus would be second — that must NOT happen.
    refute_equal items(:search_vehicle_bus), results[1]
  end

  test "sorts search_vehicle items by int field (doors) descending" do
    doors_field = fields(:search_vehicle_doors)
    browse = ItemList::Filter.new(
      :item_type => item_types(:search_vehicle),
      :sort_field => doors_field,
      :sort => "DESC"
    )
    results = browse.items.to_a

    # Numerically largest (11) first, numerically smallest (0) last.
    assert_equal items(:search_vehicle_bus),        results.first
    assert_equal items(:search_vehicle_motorcycle), results.last
  end

  test "items_for_navigation returns full unpaginated list regardless of per-page limit" do
    browse = ItemList::Filter.new(
      :item_type => item_types(:search_vehicle),
      :per => 2
    )
    # With per=2, the paginated .items result is capped at 2.
    assert_equal 2, browse.items.to_a.size

    # items_for_navigation must include every public vehicle (7: 6 original + bus).
    total_vehicles = item_types(:search_vehicle).public_items.count
    assert_equal total_vehicles, browse.items_for_navigation.to_a.size
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
