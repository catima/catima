module SharedExampleHelpers
  RSpec.shared_examples "Unauthorized" do
    let!(:Authorization) { "" }

    before do |example|
      submit_request(example.metadata)
    end

    it 'returns a 401 Unauthorized', skip_after: true do
      expect(response.code).to eq("401")
      body = JSON.parse(response.body)
      expect(body).to have_key("code")
      expect(body["code"]).to eq("invalid_token")
    end
  end

  RSpec.shared_examples "Forbidden" do
    let!(:catalog) { catalogs(:two) }
    let!(:catalog_id) { catalog.id }

    let!(:user_one) { users(:one) }
    let!(:Authorization) { generate_auth_header(user_one) }

    before do |example|
      submit_request(example.metadata)
    end

    it 'returns a 403 Forbidden', skip_after: true do
      expect(response.code).to eq("403")
      body = JSON.parse(response.body)
      expect(body).to have_key("code")
      expect(body["code"]).to eq("not_allowed")
    end
  end
end
