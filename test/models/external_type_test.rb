require "test_helper"

class ExternalTypeTest < ActiveSupport::TestCase
  test "#valid?" do
    vss = external_type("http://vss.naxio.ch/keywords/default/api/v1")
    github = external_type("https://api.github.com/repos/rails/rails")
    non_existent = external_type("http://vss.naxio.ch/does-not-exist")

    assert(vss.valid?)
    refute(github.valid?)
    refute(non_existent.valid?)
  end

  private

  def external_type(url)
    ExternalType.new(url, :client => ExternalType::Client.new)
  end
end
