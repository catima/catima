require "test_helper"

class ExternalType::ClientTest < ActiveSupport::TestCase
  test "parses JSON" do
    json = client.get("https://api.github.com/repos/rails/rails")
    assert_equal("rails", json["name"])
  end

  test "raises on 404" do
    assert_raises(ExternalType::Client::NotFound) do
      client.get("https://api.github.com/repos/rails/does-not-exist")
    end
  end

  private

  def client
    ExternalType::Client.new
  end
end
