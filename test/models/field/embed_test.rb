require "test_helper"

class Field::EmbedTest < ActiveSupport::TestCase
  test "embed validator" do
    record = Item.first
    item_type = record.item_type
    attrib = item_type.fields.first.uuid
    is_url = true
    domains = ["www.youtube.com"]
    value = "https://www.youtube.com"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://youtube.com"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.youtube.com/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://sub.youtube.com/MLSKDFJG0"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.sub.youtube.com/MLSKDFJG0"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.vimeo.com"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))

    domains = ["*.youtube.com"]
    value = "https://www.youtube.com"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://youtube.com"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.youtube.com/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://sub.youtube.com/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.sub.youtube.com/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.vimeo.com"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.youtube.ch"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))

    domains = ["www.youtube.*"]
    value = "https://www.youtube.ch"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://youtube.ch"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.youtube.ch/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://sub.youtube.ch/MLSKDFJG0"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.sub.youtube.ch/MLSKDFJG0"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.vimeo.com"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))

    domains = ["*.youtube.*"]
    value = "https://www.youtube.ch"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://youtube.ch"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.youtube.ch/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://sub.youtube.ch/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.sub.youtube.ch/MLSKDFJG0"
    assert(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
    value = "https://www.vimeo.com"
    refute(Field::Embed::EmbedValidator.new.send(:validate_by_domains, value, record, attrib, is_url, domains))
  end
end
