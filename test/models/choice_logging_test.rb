require "test_helper"

class ChoiceLoggingTest < ActiveSupport::TestCase
  setup do
    @author = users(:two_admin)
    @catalog = catalogs(:two)
    @choice_set = choice_sets(:two_languages)
  end

  def last_log
    EntryLog.order(:id).last
  end

  test "updating a choice logs an UPDATE" do
    choice = choices(:two_english_uk)

    assert_difference("EntryLog.count", 1) do
      choice.update_and_log({ short_name_en: "British English" }, author: @author, catalog: @catalog)
    end

    assert_equal choice, last_log.subject
    assert_equal "UPDATE", last_log.action
    assert_equal @author.id, last_log.author_id
    assert_equal @catalog, last_log.catalog
    assert last_log.record_changes.key?("short_name_translations")
  end

  test "updating a choice without changes does not log" do
    choice = choices(:two_english_uk)

    assert_no_difference("EntryLog.count") do
      choice.update_and_log({ short_name_en: choice.short_name_en }, author: @author, catalog: @catalog)
    end
  end

  test "creating a choice with a position logs a CREATE" do
    choice = Choice.new(choice_set: @choice_set, catalog: @catalog, short_name_en: "German")

    assert_difference("EntryLog.count", 1) do
      assert choice.save_with_position("last", author: @author, catalog: @catalog)
    end

    assert_equal choice, last_log.subject
    assert_equal "CREATE", last_log.action
  end

  test "creating a child choice at the first position shifts its siblings" do
    uk = choices(:two_english_uk)
    us = choices(:two_english_us)
    uk.update!(position: 1)
    us.update!(position: 2)
    choice = Choice.new(choice_set: @choice_set, catalog: @catalog, parent_id: choices(:two_english).id, short_name_en: "Irish English")

    assert choice.save_with_position("first", author: @author, catalog: @catalog)

    assert_equal 1, choice.position
    assert_equal 2, uk.reload.position
    assert_equal 3, us.reload.position
  end

  test "creating a root choice at the first position shifts the other root choices" do
    english = choices(:two_english)
    english.update!(position: 1)
    choice = Choice.new(choice_set: @choice_set, catalog: @catalog, short_name_en: "German")

    assert choice.save_with_position("first", author: @author, catalog: @catalog)

    assert_equal 1, choice.position
    assert_equal 2, english.reload.position
  end

  test "creating a choice at the last position appends it after its siblings" do
    choice = Choice.new(choice_set: @choice_set, catalog: @catalog, parent_id: choices(:two_english).id, short_name_en: "Irish English")

    assert choice.save_with_position("last", author: @author, catalog: @catalog)

    assert_equal choices(:two_english).childrens.count, choice.position
  end

  test "a failed save_with_position rolls back the sibling shifts" do
    english = choices(:two_english)
    english.update!(position: 1)
    choice = Choice.new(choice_set: @choice_set, catalog: @catalog, short_name_en: "German")
    choice.define_singleton_method(:save) { |*| false }

    assert_no_difference("EntryLog.count") do
      refute choice.save_with_position("first", author: @author, catalog: @catalog)
    end

    assert_equal 1, english.reload.position
  end

  test "destroying a choice logs a DELETE" do
    choice = choices(:two_english_uk)

    assert_difference("EntryLog.count", 1) do
      choice.destroy_and_log(author: @author, catalog: @catalog)
    end

    assert_equal "DELETE", last_log.action
    assert_equal choice.id, last_log.subject_id
  end

  test "destroying a choice logs a DELETE for each of its descendants" do
    parent = choices(:two_english)
    ids = [parent, *parent.descendants].map(&:id)
    assert_equal 4, ids.size

    assert_difference("EntryLog.count", 4) do
      parent.destroy_and_log(author: @author, catalog: @catalog)
    end

    logs = EntryLog.where(subject_type: "Choice", subject_id: ids, action: "DELETE")
    assert_equal ids.sort, logs.pluck(:subject_id).sort
    assert_empty Choice.where(id: ids)
  end

  test "updating a choice set logs an UPDATE" do
    assert_difference("EntryLog.count", 1) do
      @choice_set.update_and_log({ name: "Renamed" }, author: @author, catalog: @catalog)
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "UPDATE", last_log.action
    assert_equal ["Renamed"], last_log.record_changes["name"].last(1)
  end

  test "creating a choice set logs a CREATE" do
    choice_set = @catalog.choice_sets.new

    assert_difference("EntryLog.count", 1) do
      choice_set.update_and_log({ name: "Colors" }, author: @author, catalog: @catalog)
    end

    assert_equal choice_set, last_log.subject
    assert_equal "CREATE", last_log.action
  end

  test "soft deleting a choice set logs a DELETE and keeps the record" do
    assert_difference("EntryLog.count", 1) do
      assert @choice_set.soft_destroy_and_log(author: @author, catalog: @catalog)
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "DELETE", last_log.action
    assert last_log.record_changes.key?("deleted_at")
    refute ChoiceSet.find(@choice_set.id).not_deleted?
  end

  test "soft deleting an invalid choice set fails without logging" do
    @choice_set.name = ""

    assert_no_difference("EntryLog.count") do
      assert_nil @choice_set.soft_destroy_and_log(author: @author, catalog: @catalog)
    end
  end

  test "soft_destroy_and_log! raises for an invalid record" do
    @choice_set.name = ""

    assert_no_difference("EntryLog.count") do
      assert_raises(ActiveRecord::RecordInvalid) do
        @choice_set.soft_destroy_and_log!(author: @author, catalog: @catalog)
      end
    end
  end

  test "log_update logs moved choices once, as an UPDATE of the choice set" do
    moves = { "English (#1)" => { "position" => [2, 1] } }

    assert_difference("EntryLog.count", 1) do
      @choice_set.log_update(author: @author, catalog: @catalog, additional_logs: { "choices_moved" => moves })
    end

    assert_equal @choice_set, last_log.subject
    assert_equal "UPDATE", last_log.action
    assert_equal moves, last_log.record_changes["choices_moved"]
  end

  test "log_update does not log when nothing moved" do
    assert_no_difference("EntryLog.count") do
      @choice_set.log_update(author: @author, catalog: @catalog, additional_logs: { "choices_moved" => {} })
    end
  end
end
