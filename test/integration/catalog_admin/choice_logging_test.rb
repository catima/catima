require "test_helper"

class CatalogAdmin::ChoiceLoggingTest < ActionDispatch::IntegrationTest
  setup do
    @catalog = catalogs(:two)
    @choice_set = choice_sets(:two_languages)
    log_in_as("two-admin@example.com", "password")
  end

  def last_log
    EntryLog.order(:id).last
  end

  test "creating a choice set logs a CREATE" do
    assert_difference("EntryLog.where(action: 'CREATE', subject_type: 'ChoiceSet').count", 1) do
      page.driver.post(catalog_admin_choice_sets_path(@catalog, "en"), choice_set: { name: "Colors" })
    end

    assert_equal "Colors", last_log.subject.name
    assert_equal users(:two_admin).id, last_log.author_id
  end

  test "renaming a choice set logs an UPDATE" do
    assert_difference("EntryLog.where(action: 'UPDATE', subject_type: 'ChoiceSet').count", 1) do
      page.driver.submit(:patch, catalog_admin_choice_set_path(@catalog, "en", @choice_set), choice_set: { name: "Renamed" })
    end

    assert_equal @choice_set, last_log.subject
  end

  test "creating a choice logs a CREATE" do
    assert_difference("EntryLog.where(action: 'CREATE', subject_type: 'Choice').count", 1) do
      page.driver.post(
        catalog_admin_choice_set_choices_path(@catalog, "en", @choice_set),
        choice: { short_name_en: "German", position: "last" }
      )
    end

    assert_equal "German", last_log.subject.short_name_en
  end

  test "editing a choice logs an UPDATE" do
    choice = choices(:two_english_uk)

    assert_difference("EntryLog.where(action: 'UPDATE', subject_type: 'Choice').count", 1) do
      page.driver.submit(
        :patch,
        catalog_admin_choice_set_choice_path(@catalog, "en", @choice_set, choice),
        choice: { short_name_en: "British English" }
      )
    end

    assert_equal choice, last_log.subject
  end

  test "deleting a choice logs it and its children" do
    parent = choices(:two_english)
    ids = [parent, *parent.descendants].map(&:id)

    assert_difference("EntryLog.where(action: 'DELETE', subject_type: 'Choice').count", ids.size) do
      page.driver.submit(:delete, catalog_admin_choice_set_choice_path(@catalog, "en", @choice_set, parent), {})
    end

    assert_equal ids.sort, EntryLog.where(action: "DELETE", subject_type: "Choice").pluck(:subject_id).sort
    assert_equal users(:two_admin).id, last_log.author_id
  end

  # Posts the children of "English" in the given order, as the drag and drop
  # does, with the choice that was dragged.
  def reorder_children_of_english(*children, moved: nil)
    params = { positions: [{ parent_id: choices(:two_english).id, children_ids: children.map(&:id) }] }
    params[:moved_id] = moved.id if moved
    page.driver.post(update_positions_catalog_admin_choice_set_choices_path(@catalog, "en", @choice_set), params)
  end

  def english_children_in_order(*children)
    children.each_with_index { |child, index| child.update!(position: index + 1) }
  end

  test "reordering choices logs the dragged choice on the choice set" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    english_children_in_order(uk, us)

    assert_difference("EntryLog.count", 1) do
      reorder_children_of_english(us, uk, moved: us)
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "UPDATE", last_log.action
    assert_equal({ "#{us.short_name} (##{us.id})" => { "position" => [2, 1] } }, last_log.record_changes["choices_moved"])
    assert_equal 1, us.reload.position
    assert_equal 2, uk.reload.position
  end

  test "swapping two choices logs the one that was dragged" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    english_children_in_order(uk, us)

    reorder_children_of_english(us, uk, moved: uk)

    assert_equal({ "#{uk.short_name} (##{uk.id})" => { "position" => [1, 2] } }, last_log.record_changes["choices_moved"])
  end

  test "dropping a choice where it was does not log" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    english_children_in_order(uk, us)

    assert_no_difference("EntryLog.count") do
      reorder_children_of_english(uk, us, moved: uk)
    end
  end

  test "moving a choice under another parent logs its new parent" do
    english = choices(:two_english)
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    positions = [
      { parent_id: us.id, children_ids: [uk.id] },
      { parent_id: english.id, children_ids: [us.id] }
    ]

    assert_difference("EntryLog.count", 1) do
      page.driver.post(
        update_positions_catalog_admin_choice_set_choices_path(@catalog, "en", @choice_set),
        positions: positions, moved_id: uk.id
      )
    end

    assert_equal [english.id, us.id], last_log.record_changes["choices_moved"]["#{uk.short_name} (##{uk.id})"]["parent_id"]
    assert_equal us.id, uk.reload.parent_id
  end

  test "a dragged choice that is not in the request is not logged" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    english_children_in_order(uk, us)

    assert_no_difference("EntryLog.count") do
      reorder_children_of_english(us, uk, moved: choices(:two_english))
    end
  end

  test "reordering choices without saying which was dragged still saves the order" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    english_children_in_order(uk, us)

    assert_no_difference("EntryLog.count") do
      reorder_children_of_english(us, uk)
    end

    assert_equal 1, us.reload.position
  end

  test "deleting a choice set logs a DELETE and soft deletes it" do
    assert_difference("EntryLog.count", 1) do
      page.driver.submit(:delete, catalog_admin_choice_set_path(@catalog, "en", @choice_set), {})
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "DELETE", last_log.action
    refute @choice_set.reload.not_deleted?
  end
end
