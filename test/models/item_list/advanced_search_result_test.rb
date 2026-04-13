# rubocop:disable Layout/LineLength

require "test_helper"

class ItemList::AdvancedSearchResultTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
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
    response_array = %w[choice_100_bc_500 choice_1_1_300 choice_1_1_300_bc choice_100_500 choice_100_500_bc choice_300_400 choice_400_500 choice_1_1_300_400_500 date_1_1_300 date_1_1_300_bc date_1_1_400 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_before_1_1_300_bc date_between_1_1_300_31_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300_bc date_between_1_1_300_bc_31_1_300]

    search = ItemList::AdvancedSearchResult.new(model: model)
    assert_same_elements(
      search.items.map { |i| i.data["complex_datation_name"] },
      response_array
    )
  end

  def test_search_date_time_between_1_1_300_31_1_300
    model = advanced_searches(:between_1_1_300_31_1_300)
    response_array = %w[choice_100_500 choice_100_bc_500 choice_1_1_300 choice_300_400 date_1_1_300 date_between_1_1_300_31_1_300 date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_100_31_1_500 date_between_1_1_300_bc_31_1_300]
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
    response_array = %w[date_after_1_1_300 date_after_1_1_300_bc date_before_1_1_300 date_between_1_1_300_bc_31_1_300 date_1_1_300 date_1_1_400 date_between_1_1_100_31_1_500 date_between_1_1_300_31_1_300]
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

  test "filters items by decimal field criteria (rank less than 2.0)" do
    criteria = {
      "one_author_rank_uuid" => {
        "field_condition" => "and",
        "less_than" => "2.0"
      }
    }
    model = AdvancedSearch.new(
      :catalog => catalogs(:one),
      :item_type => item_types(:one_author),
      :criteria => criteria
    )
    search = ItemList::AdvancedSearchResult.new(model: model)
    results = search.items.to_a

    assert_includes(results, items(:one_author_stephen_king)) # rank=1.88891 < 2.0
    assert_includes(results, items(:one_author_very_first))   # rank=0.425 < 2.0
    refute_includes(results, items(:one_author_very_old))     # rank=2.12, not < 2.0
    refute_includes(results, items(:one_author_very_last))    # rank=100.552, not < 2.0
    refute_includes(results, items(:one_author_very_young))   # no rank set
  end

  test "filters items by reference field criteria (collaborator equals item id)" do
    target = items(:one_author_very_young)
    criteria = {
      "one_author_collaborator_uuid" => {
        "field_condition" => "and",
        "default" => target.id.to_s
      }
    }
    model = AdvancedSearch.new(
      :catalog => catalogs(:one),
      :item_type => item_types(:one_author),
      :criteria => criteria
    )
    search = ItemList::AdvancedSearchResult.new(model: model)
    results = search.items.to_a

    # very_old's collaborator is very_young → included
    assert_includes(results, items(:one_author_very_old))
    # stephen_king's collaborator is very_old, not very_young → excluded
    refute_includes(results, items(:one_author_stephen_king))
  end

  test "filters items by date field criteria (born exact date)" do
    criteria = {
      "one_author_born_uuid" => {
        "field_condition" => "and",
        "condition" => "exact",
        "start" => { "exact" => { "Y" => "1947", "M" => "9", "D" => "21" } },
        "end" => { "exact" => { "D" => "", "M" => "", "Y" => "" } }
      }
    }
    model = AdvancedSearch.new(
      :catalog => catalogs(:one),
      :item_type => item_types(:one_author),
      :criteria => criteria
    )
    search = ItemList::AdvancedSearchResult.new(model: model)
    results = search.items.to_a

    # stephen_king born Y:1947 M:9 D:21 → matches exactly
    assert_includes(results, items(:one_author_stephen_king))
    # very_old born Y:1947 M:11 D:11 → month differs → excluded
    refute_includes(results, items(:one_author_very_old))
    # items with no born field → excluded by append_where_date_is_set
    refute_includes(results, items(:one_author_very_young))
  end

  test "results are sorted alphabetically by primary field after filtering" do
    criteria = {
      "one_author_rank_uuid" => {
        "field_condition" => "and",
        "greater_than" => "0"
      }
    }
    model = AdvancedSearch.new(
      :catalog => catalogs(:one),
      :item_type => item_types(:one_author),
      :criteria => criteria
    )
    search = ItemList::AdvancedSearchResult.new(model: model)
    names = search.items.to_a.map { |i| i.data["one_author_name_uuid"] }.compact

    refute_empty names
    assert_equal names, names.sort
  end
end
# rubocop:enable Layout/LineLength
