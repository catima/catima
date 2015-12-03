require "test_helper"

class ExternalTypeTest < ActiveSupport::TestCase
  test "uses 5 minute cache by default" do
    ext = ExternalType.new("foo")

    assert_instance_of(ExternalType::ClientWithCache, ext.client)
    assert_equal(Rails.cache, ext.client.cache)
    assert_equal(5.minutes, ext.client.options[:expires_in])
  end

  test "#valid?" do
    github = external_type("https://api.github.com/repos/rails/rails")
    non_existent = external_type("http://vss.naxio.ch/does-not-exist")

    assert(vss.valid?)
    refute(github.valid?)
    refute(non_existent.valid?)
  end

  test "#name" do
    assert_equal("Keyword", vss.name)
    assert_equal("Keyword", vss.name(:en))
    assert_equal("Schlüsselwort", vss.name(:de))
    assert_equal("Mot-clé", vss.name(:fr))
  end

  test "#locales" do
    assert_equal(%w(fr de en), vss.locales)
  end

  # TODO: test once API is responding correctly to this endpoints
  # test "#find_item"

  test "#all_items" do
    items = vss.all_items

    assert_instance_of(Array, items)
    refute_empty(items)
    birds = items.find { |i| i.name(:en) == "Birds" }
    refute_nil(birds.id)
    assert_equal("Vögel", birds.name(:de))
    assert_equal("oiseaux", birds.name(:fr))
  end

  private

  def vss
    external_type("http://vss.naxio.ch/keywords/default/api/v1")
  end

  def external_type(url)
    ExternalType.new(url, :client => ExternalType::Client.new)
  end
end
