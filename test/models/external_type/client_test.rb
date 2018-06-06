require "test_helper"

class ExternalType::ClientTest < ActiveSupport::TestCase
  include WithVCR

  test "parses JSON" do
    json = with_expiring_vcr_cassette do
      client.get("https://api.github.com/repos/rails/rails")
    end
    assert_equal("rails", json["name"])
  end

  test "raises on 404" do
    assert_raises(ExternalType::Client::NotFound) do
      with_expiring_vcr_cassette do
        client.get("https://api.github.com/repos/rails/does-not-exist")
      end
    end
  end

  private

  def client
    ExternalType::Client.new
  end
end
