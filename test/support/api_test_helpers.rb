module APITestHelpers
  include ActiveModelSerializers::Test::Schema

  private

  def json_response
    @_json_response ||= JSON.parse(response.body)
  end
end
