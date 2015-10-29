require "test_helper"

class DataStoreTest < ActiveSupport::TestCase
  test "#get and #set single non-localized value" do
    assert_nil(single.get)
    single.set("hello")
    assert_equal("hello", single.get)
  end

  test "#get and #set multi non-localized value" do
    assert_equal([], multi.get)
    single.set(%w(hello world))
    assert_equal(%w(hello world), multi.get)
  end

  test "#get and #set single localized value" do
    assert_nil(single_en.get)
    assert_nil(single_fr.get)
    single_en.set("hello")
    single_fr.set("bonjour")
    assert_equal("hello", single_en.get)
    assert_equal("bonjour", single_fr.get)
  end

  test "#get and #set multi localized value" do
    assert_equal([], multi_en.get)
    assert_equal([], multi_fr.get)
    multi_en.set(%w(one two))
    multi_fr.set(%w(un deux))
    assert_equal(%w(one two), multi_en.get)
    assert_equal(%w(un deux), multi_fr.get)
  end

  test "coerces single non-localized value when schema changes" do
    single.set("hello")
    assert_equal("hello", single_en.get)
    assert_equal("hello", single_fr.get)
    assert_equal(["hello"], multi_en.get)
    assert_equal(["hello"], multi_fr.get)
  end

  test "coerces single localized value when schema changes" do
    single_en.set("hello")
    assert_equal("hello", single.get)
    assert_equal(["hello"], multi_en.get)
    assert_equal([], multi_fr.get)
  end

  test "coerces multi non-localized value when schema changes" do
    multi.set(%w(hello world))
    assert_equal("hello", single_en.get)
    assert_equal("hello", single_fr.get)
    assert_equal(%w(hello world), multi_en.get)
    assert_equal(%w(hello world), multi_fr.get)
  end

  test "coerces multi localized value when schema changes" do
    multi_en.set(%w(hello world))
    assert_equal("hello", single.get)
    assert_equal("hello", single_en.get)
    assert_nil(single_fr.get)
  end

  test "single valued non-localized storage format" do
    single.set("hello")
    assert_equal({ "key" => "hello" }, data)
  end

  test "multivalued non-localized storage format" do
    multi.set(%w(hello world))
    assert_equal({ "key" => %w(hello world) }, data)
  end

  test "single valued localized storage format" do
    single_en.set("hello")
    single_fr.set("bonjour")
    assert_equal(
      {
        "key" => {
          "_translations" => {
            "en" => "hello",
            "fr" => "bonjour"
          }
        }
      },
      data
    )
  end

  test "multivalued valued localized storage format" do
    multi_en.set(%w(one two))
    multi_fr.set(%w(un deux))
    assert_equal(
      {
        "key" => {
          "_translations" => {
            "en" => %w(one two),
            "fr" => %w(un deux)
          }
        }
      },
      data
    )
  end

  private

  def data
    @data ||= {}
  end

  def single
    store(:multivalued => false, :locale => nil)
  end

  def single_en
    store(:multivalued => false, :locale => :en)
  end

  def single_fr
    store(:multivalued => false, :locale => :fr)
  end

  def multi
    store(:multivalued => true, :locale => nil)
  end

  def multi_en
    store(:multivalued => true, :locale => :en)
  end

  def multi_fr
    store(:multivalued => true, :locale => :fr)
  end

  def store(**kwargs)
    DataStore.new(:data => data, :key => "key", **kwargs)
  end
end
