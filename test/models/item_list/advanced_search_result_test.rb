# rubocop:disable Layout/LineLength

require "test_helper"

class ItemList::AdvancedSearchResultTest < ActiveSupport::TestCase
  test "search multiple fields" do
    criteria = {
      "search_vehicle_make_uuid" => {
        "field_condition" => "and",
        "exact" => "toyota"
      },
      "search_vehicle_model_uuid" => {
        "field_condition" => "exclude",
        "one_word" => "camry"
      },
      "search_vehicle_doors_uuid" => { "exact" => "" },
      "search_vehicle_style_uuid" => { "exact" => "" }
    }
    model = AdvancedSearch.new(
      :catalog => catalogs(:search),
      :item_type => item_types(:search_vehicle),
      :criteria => criteria
    )
    search = ItemList::AdvancedSearchResult.new(:model => model)

    results = search.items.to_a
    assert_includes(results, items(:search_vehicle_toyota_highlander))
    assert_includes(results, items(:search_vehicle_toyota_prius))
    refute_includes(results, items(:search_vehicle_toyota_camry_hybrid))
    refute_includes(results, items(:search_vehicle_toyota_camry))
  end

  test "only shows public items" do
    model = AdvancedSearch.new(
      :catalog => catalogs(:reviewed),
      :item_type => item_types(:reviewed_book),
      :criteria => {}
    )
    search = ItemList::AdvancedSearchResult.new(:model => model)

    results = search.items.to_a
    assert_includes(results, items(:reviewed_book_finders_keepers_approved))
    refute_includes(results, items(:reviewed_book_end_of_watch))
  end

  def test_search_date_time_exact
    model = advanced_searches(:exact_1_1_300)
    response_array = %w[choice_1_1_300 date_1_1_300 choice_1_1_300_400_500]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_exact_bc
    model = advanced_searches(:exact_1_1_300_bc)
    response_array = %w[choice_1_1_300_bc date_1_1_300_bc]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_before
    model = advanced_searches(:before_1_1_300)
    response_array = %w[choice_100_bc_500 choice_1_1_300 choice_1_1_300_bc choice_100_500 choice_100_500_bc choice_300_400 choice_300_400_bc choice_400_500_bc choice_1_1_300_400_500 date_1_1_300 date_1_1_300_bc date_1_1_400_bc date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_300_31_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300_bc date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_before_choices_excluded
    model = advanced_searches(:before_1_1_300_choices_excluded)
    response_array = %w[date_1_1_300 date_1_1_300_bc date_1_1_400_bc date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_300_31_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300_bc date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_before_datation_excluded
    model = advanced_searches(:before_1_1_300_datation_excluded)
    response_array = %w[choice_100_bc_500 choice_1_1_300 choice_1_1_300_bc choice_100_500 choice_100_500_bc choice_300_400 choice_300_400_bc choice_400_500_bc choice_1_1_300_400_500]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_before_bc
    model = advanced_searches(:before_1_1_300_bc)
    response_array = %w[choice_1_1_300_bc choice_100_500_bc choice_300_400_bc choice_400_500_bc date_1_1_300_bc date_1_1_400_bc date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_300_bc_31_1_300_bc date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_after
    model = advanced_searches(:after_1_1_300)
    response_array = %w[choice_100_bc_500 choice_1_1_300 choice_100_500 choice_300_400 choice_400_500 choice_1_1_300_400_500 date_1_1_300 date_1_1_400 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_300_31_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_after_choices_excluded
    model = advanced_searches(:after_1_1_300_choices_excluded)
    response_array = %w[date_1_1_300 date_1_1_400 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_300_31_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_after_datation_excluded
    model = advanced_searches(:after_1_1_300_datation_excluded)
    response_array = %w[choice_100_bc_500 choice_1_1_300 choice_100_500 choice_300_400 choice_400_500 choice_1_1_300_400_500]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_after_bc
    model = advanced_searches(:after_1_1_300_bc)
    response_array = %w[ choice_100_bc_500 choice_1_1_300 choice_1_1_300_bc choice_100_500 choice_100_500_bc choice_300_400  choice_400_500 choice_1_1_300_400_500 date_1_1_300 date_1_1_300_bc date_1_1_400 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_300_31_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300_bc date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_between_1_1_300_31_1_300
    model = advanced_searches(:between_1_1_300_31_1_300)
    response_array = %w[ choice_100_500 choice_100_bc_500 choice_1_1_300 choice_300_400 date_1_1_300 date_between_1_1_300_31_1_300 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300]
    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_between_1_1_300_bc_31_1_300_bc
    model = advanced_searches(:between_1_1_300_bc_31_1_300_bc)
    response_array = %w[choice_100_500_bc choice_1_1_300_bc date_1_1_300_bc date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_300_bc_31_1_300 date_between_1_1_300_bc_31_1_300_bc]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_between_1_1_300_bc_31_1_300
    model = advanced_searches(:between_1_1_300_bc_31_1_300)
    response_array = %w[choice_100_500 choice_100_500_bc choice_100_bc_500 choice_1_1_300 choice_1_1_300_bc choice_300_400 date_1_1_300 date_1_1_300_bc date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_100_31_1_500 date_between_1_1_300_31_1_300 date_between_1_1_300_bc_31_1_300 date_between_1_1_300_bc_31_1_300_bc]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_whith_a_choice
    model = advanced_searches(:with_a_choice)
    response_array = %w[choice_1_1_300 choice_1_1_300_400_500 date_1_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_whith_a_choice_with_childrens
    model = advanced_searches(:with_a_choice_with_childrens)
    response_array = %w[choice_100_500 choice_300_400 choice_400_500 choice_1_1_300_400_500 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_300_bc_31_1_300 date_1_1_300 date_1_1_400 date_between_1_1_100_31_1_500 date_between_1_1_300_31_1_300]
    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_with_a_choice_with_childrens_choices_excluded
    model = advanced_searches(:with_a_choice_with_childrens_choices_excluded)
    response_array = %w[date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_300_bc_31_1_300 date_1_1_300 date_1_1_400 date_between_1_1_100_31_1_500 date_between_1_1_300_31_1_300 ]
    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_with_a_choice_with_childrens_datation_excluded
    model = advanced_searches(:with_a_choice_with_childrens_datation_excluded)
    response_array = %w[choice_100_500 choice_300_400 choice_400_500 choice_1_1_300_400_500]
    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end
end
# rubocop:enable Layout/LineLength
