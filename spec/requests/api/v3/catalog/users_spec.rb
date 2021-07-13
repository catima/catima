# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/users', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:one_admin) { users(:one_admin) }
  let!(:Authorization) { generate_auth_header(one_admin) }

  let!(:catalog_one) { catalogs(:one) }
  let!(:catalog_id) { catalog_one.id }

  path '/api/v3/{catalog_id}/users' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'

    get("List Catalog's Users") do
      tags 'Catalog'
      consumes 'application/json'
      security [BearerAuth: []]
      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
        end
      end

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end

      response(403, 'Forbidden') do
        include_examples "Forbidden"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
