require "test_helper"

class Search::NavigationTest < ActiveSupport::TestCase
  class MockResults
    attr_reader :array

    def initialize(array)
      @array = array
      @offset = 0
      @limit = array.length
    end

    def offset(num)
      @offset = num
      self
    end

    def limit(num)
      @limit = num
      self
    end

    def to_a
      array[@offset...(@offset + @limit)]
    end
  end

  test "next and previous are empty for an empty result" do
    navigation = build_nav([], :a, 0)
    assert_nil(navigation.previous)
    assert_nil(navigation.next)
    assert_nil(navigation.offset_actual)
    assert_nil(navigation.previous_offset)
    assert_nil(navigation.next_offset)
  end

  test "next and previous for result set of 1" do
    navigation = build_nav(%i(a), :a, 0)
    assert_nil(navigation.previous)
    assert_nil(navigation.next)
    assert_equal(0, navigation.offset_actual)
    assert_nil(navigation.previous_offset)
    assert_nil(navigation.next_offset)
  end

  test "next and previous for beginning of result set of 2" do
    navigation = build_nav(%i(a b), :a, 0)
    assert_nil(navigation.previous)
    assert_equal(:b, navigation.next)
    assert_equal(0, navigation.offset_actual)
    assert_nil(navigation.previous_offset)
    assert_equal(1, navigation.next_offset)
  end

  test "next and previous for end of result set of 2" do
    navigation = build_nav(%i(a b), :b, 1)
    assert_equal(:a, navigation.previous)
    assert_nil(navigation.next)
    assert_equal(1, navigation.offset_actual)
    assert_equal(0, navigation.previous_offset)
    assert_nil(navigation.next_offset)
  end

  test "next and previous for beginning of large result set" do
    navigation = build_nav(%i(a b c d e f g h), :a, 0)
    assert_nil(navigation.previous)
    assert_equal(:b, navigation.next)
    assert_equal(0, navigation.offset_actual)
    assert_nil(navigation.previous_offset)
    assert_equal(1, navigation.next_offset)
  end

  test "next and previous for second of large result set" do
    navigation = build_nav(%i(a b c d e f g h), :b, 1)
    assert_equal(:a, navigation.previous)
    assert_equal(:c, navigation.next)
    assert_equal(1, navigation.offset_actual)
    assert_equal(0, navigation.previous_offset)
    assert_equal(2, navigation.next_offset)
  end

  test "next and previous for third of large result set" do
    navigation = build_nav(%i(a b c d e f g h), :c, 2)
    assert_equal(:b, navigation.previous)
    assert_equal(:d, navigation.next)
    assert_equal(2, navigation.offset_actual)
    assert_equal(1, navigation.previous_offset)
    assert_equal(3, navigation.next_offset)
  end

  test "next and previous for last of large result set" do
    navigation = build_nav(%i(a b c d e f g h), :h, 7)
    assert_equal(:g, navigation.previous)
    assert_nil(navigation.next)
    assert_equal(7, navigation.offset_actual)
    assert_equal(6, navigation.previous_offset)
    assert_nil(navigation.next_offset)
  end

  test "next and previous when offset is off by 1" do
    navigation = build_nav(%i(a b c d e f g h), :d, 4)
    assert_equal(:c, navigation.previous)
    assert_equal(:e, navigation.next)
    assert_equal(3, navigation.offset_actual)
    assert_equal(2, navigation.previous_offset)
    assert_equal(4, navigation.next_offset)
  end

  test "next and previous when offset is off by 2" do
    navigation = build_nav(%i(a b c d e f g h), :d, 5)
    assert_equal(:c, navigation.previous)
    assert_equal(:e, navigation.next)
    assert_equal(3, navigation.offset_actual)
    assert_equal(2, navigation.previous_offset)
    assert_equal(4, navigation.next_offset)
  end

  test "next and previous when offset is off by 3" do
    navigation = build_nav(%i(a b c d e f g h), :d, 6)
    assert_equal(:c, navigation.previous)
    assert_equal(:e, navigation.next)
    assert_equal(3, navigation.offset_actual)
    assert_equal(2, navigation.previous_offset)
    assert_equal(4, navigation.next_offset)
  end

  test "next and previous when offset is off by 4" do
    navigation = build_nav(%i(a b c d e f g h), :d, 7)
    assert_equal(:c, navigation.previous)
    assert_equal(:e, navigation.next)
    assert_equal(3, navigation.offset_actual)
    assert_equal(2, navigation.previous_offset)
    assert_equal(4, navigation.next_offset)
  end

  test "next and previous when offset is off by 5" do
    navigation = build_nav(%i(a b c d e f g h), :d, 8)
    assert_nil(navigation.previous)
    assert_equal(:e, navigation.next)
    assert_equal(3, navigation.offset_actual)
    assert_nil(navigation.previous_offset)
    assert_equal(4, navigation.next_offset)
  end

  test "next and previous when current is not in result" do
    navigation = build_nav(%i(a b c d e f g h), :i, 5)
    assert_nil(navigation.previous)
    assert_nil(navigation.next)
    assert_nil(navigation.offset_actual)
    assert_nil(navigation.previous_offset)
    assert_nil(navigation.next_offset)
  end

  private

  def build_nav(array, current, offset)
    Search::Navigation.new(
      :results => MockResults.new(array),
      :current => current,
      :offset => offset
    )
  end
end
