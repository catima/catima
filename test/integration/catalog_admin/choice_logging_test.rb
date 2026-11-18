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

  def reorder_children_of_english(*children)
    positions = [{ parent_id: choices(:two_english).id, children_ids: children.map(&:id) }]
    page.driver.post(update_positions_catalog_admin_choice_set_choices_path(@catalog, "en", @choice_set), positions: positions)
  end

  test "reordering choices logs a single entry on the choice set" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)

    assert_difference("EntryLog.count", 1) do
      reorder_children_of_english(us, uk)
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "UPDATE", last_log.action
    assert_equal 2, last_log.record_changes["choices_moved"].size
    assert_equal 1, us.reload.position
    assert_equal 2, uk.reload.position
  end

  test "reordering choices into the same order does not log again" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    reorder_children_of_english(us, uk)

    assert_no_difference("EntryLog.count") do
      reorder_children_of_english(us, uk)
    end
  end

  test "deleting a choice set logs a DELETE and soft deletes it" do
    assert_difference("EntryLog.count", 1) do
      page.driver.submit(:delete, catalog_admin_choice_set_path(@catalog, "en", @choice_set), {})
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "DELETE", last_log.action
    refute @choice_set.reload.not_deleted?
  end

  test "deleting an item type logs a DELETE" do
    item_type = item_types(:two_author)

    assert_difference("EntryLog.where(action: 'DELETE', subject_type: 'ItemType').count", 1) do
      page.driver.submit(:delete, catalog_admin_item_type_path(@catalog, "en", item_type), {})
    end

    assert_equal item_type, last_log.subject
    refute item_type.reload.deleted_at.nil?
  end
end
