require "test_helper"

class DataStore::JsonAttributeTest < ActiveSupport::TestCase
  class TestItem
    include ActiveModel::Validations
    attr_accessor :name

    DataStore::JsonAttribute.define(self, :name)
  end

  setup do
    @item = TestItem.new
  end

  test "reader is defined" do
    assert(@item.respond_to?(:name_json))
  end

  test "reader does not transform existing non-array, non-hash values" do
    @item.name = "foo"
    assert_equal('"foo"', @item.name_json)
  end

  test "writer is defined" do
    assert(@item.respond_to?(:name_json=))
  end

  test "writer stores value as parsed JSON" do
    @item.name_json = '{ "foo": "bar" }'
    assert_equal({ "foo" => "bar" }, @item.name)
  end

  test "writer stores blank value as nil" do
    @item.name = "existing"
    @item.name_json = ""
    assert_nil(@item.name)
  end

  test "reader provides value exactly as written" do
    json = '{      "foo": "bar" }'
    @item.name_json = json
    assert_equal(json, @item.name_json)
  end

  test "validation fails if JSON is invalid, but data is still readable" do
    invalid_json = '{ "invalid": }'
    @item.name_json = invalid_json
    refute(@item.valid?)
    assert_equal(invalid_json, @item.name_json)
  end
end
