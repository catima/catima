require "test_helper"

class ItemTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  should validate_presence_of(:catalog)
  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)

  test ".with_type returns all items if type is nil" do
    items = Item.with_type(nil)
    assert_equal(Item.all.to_sql, items.to_sql)
  end

  test ".with_type returns items belonging to specified type" do
    type = item_types(:one_book)
    found = Item.with_type(type)

    assert_includes(found, items(:one_book_end_of_watch))
    refute_includes(found, items(:one_author_stephen_king))
  end

  test "#behaving_as_type returns object with field UUID accessors" do
    item = items(:one_book_end_of_watch).behaving_as_type
    %i(one_book_title one_book_author).map(&method(:fields)).each do |field|
      assert(item.respond_to?(field.uuid))
      assert(item.respond_to?("#{field.uuid}="))
    end
  end

  test "#behaving_as_type returns object with json accessors" do
    item = items(:one_book_end_of_watch).behaving_as_type
    %i(one_book_title one_book_author).map(&method(:fields)).each do |field|
      assert(item.respond_to?("#{field.uuid}_json"))
      assert(item.respond_to?("#{field.uuid}_json="))
    end
  end

  test "items are sorted by reference field (single join to referenced items table)" do
    field = fields(:one_author_collaborator)

    # The sort SQL must join items to the referenced-author table.
    sql_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_sql
    assert_match(/LEFT JOIN items sort_ref_item_#{field.uuid}/, sql_asc)

    # Stephen King's collaborator is "Very Old" and Very Old's collaborator is
    # "Very Young".  "Very Old" < "Very Young" alphabetically, so in ASC order
    # Stephen King is first (his collaborator name sorts earliest).
    items_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC")
    assert_equal(items(:one_author_stephen_king), items_asc.first)

    # In DESC the largest collaborator name comes first: "Very Young" > "Very Old",
    # so Very Old (whose collaborator is Very Young) is first.
    item_desc = item_types(:one_author).public_items.sorted_by_field(field, direction: "DESC")
    assert_equal(items(:one_author_very_old), item_desc.first)
  end

  test "reference field join_for_sort returns nested joins when effective sort is a choice set" do
    ref_field    = fields(:one_author_collaborator)
    choice_field = fields(:one_author_category) # Field::ChoiceSet

    # Stub the effective sort field to be a ChoiceSet so we get the double-join path.
    ref_field.stubs(:effective_sort_field).returns(choice_field)
    joins = ref_field.join_for_sort
    assert joins.is_a?(Array), "expected an array of two JOIN clauses"
    assert_equal 2, joins.length
    assert_match(/LEFT JOIN items sort_ref_item_#{ref_field.uuid}/, joins[0])
    assert_match(/LEFT JOIN choices sort_choices_#{choice_field.uuid}/, joins[1])
  end

  test "items are sorted by choice set field via choices join" do
    field = fields(:search_vehicle_style)

    # ASC (en_US: "Sedan" < "SUV"): all Sedan vehicles come first, then the
    # unique SUV (Highlander), then the motorcycle whose style is empty (NULLS LAST).
    items_asc = item_types(:search_vehicle).public_items.sorted_by_field(field, direction: "ASC").to_a
    assert_equal items(:search_vehicle_toyota_highlander), items_asc[-2]
    assert_equal items(:search_vehicle_motorcycle),        items_asc.last

    # DESC (en_US: "SUV" > "Sedan"): Highlander is unambiguously first; motorcycle
    # still last (NULLS LAST regardless of direction).
    items_desc = item_types(:search_vehicle).public_items.sorted_by_field(field, direction: "DESC").to_a
    assert_equal items(:search_vehicle_toyota_highlander), items_desc.first
    assert_equal items(:search_vehicle_motorcycle),        items_desc.last
  end

  test "sorted_by_field falls back to raw string sort for non-sortable fields" do
    field = fields(:one_author_other_collaborators) # Field::Reference, multiple: true
    assert_not field.sortable?, "field must be non-sortable to exercise the fallback path"

    # The generated SQL must use the raw JSONB text value, not a JOIN-based sort.
    sql_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_sql
    assert_match(/items\.data->>'#{field.uuid}' ASC NULLS LAST/, sql_asc)

    sql_desc = item_types(:one_author).public_items.sorted_by_field(field, direction: "DESC").to_sql
    assert_match(/items\.data->>'#{field.uuid}' DESC NULLS LAST/, sql_desc)

    # In the test DB, three authors have other-collaborators set:
    #   Stephen King       → ["<apprentice_id>"]            (smallest JSON-string value)
    #   Very Young         → ["<stephen_king_id>","<very_old_id>"]
    #   Young apprentice   → ["<stephen_king_id>","<very_old_id>"]
    # Everyone else has NULL → NULLS LAST.
    items_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_a
    assert_equal items(:one_author_stephen_king), items_asc.first
    assert items_asc.last.data[field.uuid].blank?, "authors without a collaborator should sort last (NULLS LAST)"
  end

  test "items are sorted by primary field by default" do
    items = item_types(:one_author).public_sorted_items
    assert_equal(items.first, items(:one_author_very_first))
    assert_equal(items.to_a.last, items(:one_author_empty_fields))
  end

  test "items are sorted by reference field when referenced type primary field is a choice set" do
    # Assign scalar category values so the JOIN can match choice IDs correctly.
    # ChoiceSet join_for_sort uses data->'uuid'->>0 (array-first-element extraction).
    very_old   = items(:one_author_very_old)
    very_young = items(:one_author_very_young)

    very_old.data["one_author_category_uuid"] = [choices(:one_with_category).id.to_s]
    very_old.save!
    very_young.data["one_author_category_uuid"] = [choices(:one_without_category).id.to_s]
    very_young.save!

    ref_field    = fields(:one_author_collaborator)
    choice_field = fields(:one_author_category)

    # Stub the effective_sort_field so sorted_by_field follows the double-join path.
    ref_field.stubs(:effective_sort_field).returns(choice_field)

    scope = Item.where(id: [items(:one_author_stephen_king).id, items(:one_author_very_old).id])

    # ASC: stephen_king's collaborator has "With category" < "Without category"
    # → stephen_king sorts before very_old.
    results_asc = scope.sorted_by_field(ref_field, direction: "ASC").to_a
    assert_equal items(:one_author_stephen_king), results_asc.first
    assert_equal items(:one_author_very_old),     results_asc.last

    # DESC: very_old's collaborator has "Without category" > "With category"
    # → very_old sorts before stephen_king.
    results_desc = scope.sorted_by_field(ref_field, direction: "DESC").to_a
    assert_equal items(:one_author_very_old),     results_desc.first
    assert_equal items(:one_author_stephen_king), results_desc.last
  end

  test "items are sorted by decimal field numerically" do
    field = fields(:one_author_rank)

    sql_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_sql
    assert_match(/::float ASC NULLS LAST/, sql_asc)

    # Narrow to the four authors whose rank is set so positions are deterministic.
    scope = Item.where(id: [
                         items(:one_author_very_first).id,
                         items(:one_author_stephen_king).id,
                         items(:one_author_very_old).id,
                         items(:one_author_very_last).id
                       ])

    results_asc = scope.sorted_by_field(field, direction: "ASC").to_a
    assert_equal items(:one_author_very_first), results_asc.first  # 0.425
    assert_equal items(:one_author_very_last),  results_asc.last   # 100.552

    results_desc = scope.sorted_by_field(field, direction: "DESC").to_a
    assert_equal items(:one_author_very_last),  results_desc.first # 100.552
    assert_equal items(:one_author_very_first), results_desc.last  # 0.425

    # Authors with no rank come last in the full scope.
    all_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_a
    assert all_asc.last.data[field.uuid].blank?, "authors without a rank should sort last (NULLS LAST)"
  end

  test "items are sorted by datetime field chronologically" do
    field = fields(:one_author_born)

    sql_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_sql
    # The leading Y component must be cast to bigint; items with no year sort last.
    assert_match(/::bigint ASC NULLS LAST/, sql_asc)

    # Restrict to the two authors with known born dates.
    scope = Item.where(id: [items(:one_author_stephen_king).id, items(:one_author_very_old).id])

    results_asc = scope.sorted_by_field(field, direction: "ASC").to_a
    assert_equal items(:one_author_stephen_king), results_asc.first  # 1947-09-21
    assert_equal items(:one_author_very_old),     results_asc.last   # 1947-11-11

    results_desc = scope.sorted_by_field(field, direction: "DESC").to_a
    assert_equal items(:one_author_very_old),     results_desc.first # 1947-11-11
    assert_equal items(:one_author_stephen_king), results_desc.last  # 1947-09-21

    # Authors with no born date come last in the full scope.
    all_asc = item_types(:one_author).public_items.sorted_by_field(field, direction: "ASC").to_a
    assert all_asc.last.data[field.uuid].blank?, "authors without a born date should sort last (NULLS LAST)"
  end

  test "items are sorted by int field numerically not lexicographically" do
    field = fields(:search_vehicle_doors)

    sql_asc = item_types(:search_vehicle).public_items.sorted_by_field(field, direction: "ASC").to_sql
    assert_match(/::BIGINT ASC NULLS LAST/, sql_asc)

    results_asc = item_types(:search_vehicle).public_items.sorted_by_field(field, direction: "ASC").to_a
    assert_equal items(:search_vehicle_motorcycle), results_asc.first # 0
    assert_equal items(:search_vehicle_bus),        results_asc.last  # 11

    # "11" < "3" lexicographically → bus would be near the beginning without the cast.
    refute_equal items(:search_vehicle_bus), results_asc[1]

    results_desc = item_types(:search_vehicle).public_items.sorted_by_field(field, direction: "DESC").to_a
    assert_equal items(:search_vehicle_bus),        results_desc.first # 11
    assert_equal items(:search_vehicle_motorcycle), results_desc.last  # 0
  end

  test "items are sorted by reference field when referenced type primary field is a datetime" do
    ref_field      = fields(:one_author_collaborator)
    datetime_field = fields(:one_author_born)
    ref_field.stubs(:effective_sort_field).returns(datetime_field)

    # DateTime has no join of its own → only the items alias join is returned.
    join = ref_field.join_for_sort
    assert_match(/LEFT JOIN items sort_ref_item_#{ref_field.uuid}/, join)

    # Give very_young a born date so both collaborators have a date.
    # collaborators: stephen_king→very_old (born 1947-11-11), very_old→very_young (born 1980-01-01).
    very_young = items(:one_author_very_young)
    very_young.data["one_author_born_uuid"] = { "Y" => 1980, "M" => 1, "D" => 1 }
    very_young.save!

    scope = Item.where(id: [items(:one_author_stephen_king).id, items(:one_author_very_old).id])

    # ASC: stephen_king's collaborator born 1947 < very_old's collaborator born 1980.
    results_asc = scope.sorted_by_field(ref_field, direction: "ASC").to_a
    assert_equal items(:one_author_stephen_king), results_asc.first
    assert_equal items(:one_author_very_old),     results_asc.last

    # DESC: 1980 > 1947 → very_old sorts first.
    results_desc = scope.sorted_by_field(ref_field, direction: "DESC").to_a
    assert_equal items(:one_author_very_old),     results_desc.first
    assert_equal items(:one_author_stephen_king), results_desc.last
  end

  test "items are sorted by reference field when referenced type primary field is a decimal" do
    ref_field     = fields(:one_author_collaborator)
    decimal_field = fields(:one_author_rank)
    ref_field.stubs(:effective_sort_field).returns(decimal_field)

    # Decimal has no join of its own → only the items alias join is returned.
    join = ref_field.join_for_sort
    assert_match(/LEFT JOIN items sort_ref_item_#{ref_field.uuid}/, join)

    # Give very_young a rank so both collaborators have a numeric value.
    # collaborators: stephen_king→very_old (rank 2.12), very_old→very_young (rank 0.5).
    very_young = items(:one_author_very_young)
    very_young.data["one_author_rank_uuid"] = "0.5"
    very_young.save!

    scope = Item.where(id: [items(:one_author_stephen_king).id, items(:one_author_very_old).id])

    # ASC: very_old's collaborator rank 0.5 < stephen_king's collaborator rank 2.12.
    results_asc = scope.sorted_by_field(ref_field, direction: "ASC").to_a
    assert_equal items(:one_author_very_old),     results_asc.first
    assert_equal items(:one_author_stephen_king), results_asc.last

    # DESC: 2.12 > 0.5 → stephen_king sorts first.
    results_desc = scope.sorted_by_field(ref_field, direction: "DESC").to_a
    assert_equal items(:one_author_stephen_king), results_desc.first
    assert_equal items(:one_author_very_old),     results_desc.last
  end
end
