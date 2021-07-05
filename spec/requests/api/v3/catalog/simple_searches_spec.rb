require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/search', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:one_admin) { users(:one_admin) }
  let!(:Authorization) { generate_auth_header(one_admin) }

  let!(:catalog_one) { catalogs(:one) }
  let!(:catalog_id) { catalog_one.id }

  let(:search) { { q: 'one' } }
  let(:uuid) { 'unique-book-search-uuid' }

  path '/api/v3/{catalog_id}/search' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'

    post("Create a SimpleSearch in a Catalog") do
      tags 'SimpleSearch'
      consumes 'application/json'
      security [BearerAuth: []]

      parameter name: :search, in: :body, schema: {
        type: :object,
        properties: {
          q: { type: :string, description: 'search query' },
          type: { type: :string, description: 'item type slug' }
        },
        required: ['q']
      }

      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
        end
      end

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end

  path '/api/v3/{catalog_id}/search/{uuid}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'uuid', in: :path, type: :string, description: 'search uuid'

    get("Return a Catalog's SimpleSearch") do
      tags 'SimpleSearch'
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
    end
  end
end
