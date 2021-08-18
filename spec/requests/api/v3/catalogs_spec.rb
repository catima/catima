# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/catalogs', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:user) { users(:system_admin) }
  let!(:page) { 1 }
  let!(:per) { 3 }
  let!(:Authorization) { generate_auth_header(user) }

  path '/api/v3/catalogs' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false

    get('List Catalogs') do
      tags 'Catalogs'
      consumes 'application/json'
      security [BearerAuth: []]

      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
          expect(body["data"].length).to eq(3)
        end
      end

      # test catalog authentication
      let!(:api_key) { api_keys(:two).api_key }
      response(200, 'successful') do
        let!(:Authorization) { "Bearer #{api_key}" }

        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
          expect(body["data"].length).to eq(1)
        end
      end

      # test catalog authentication
      let!(:api_key_revoked) { api_keys(:two_revoked).api_key }
      response(401, 'Unauthorized') do
        let!(:Authorization) { "Bearer #{api_key_revoked}" }
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

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
