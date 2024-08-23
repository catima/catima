# rubocop:disable Metrics/BlockLength
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
      description <<-HTML.squish
        <p><b>Authorization: User+/Member+/Editor+ (according to catalog's visibility)</b></p>
      HTML

      parameter name: :search, in: :body, schema: {
        type: :object,
        properties: {
          q: { type: :string, description: 'search query' },
          item_type_slug: { type: :string, description: 'item type slug' }
        },
        required: ['q']
      }

      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
        end
      end

      # test catalog authentication
      response(200, 'successful') do
        include_examples "API_KEY_Success", :one
      end

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end

  path '/api/v3/{catalog_id}/search/{uuid}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'uuid', in: :path, type: :string, description: 'search uuid'
    parameter name: 'item_type_slug', in: :query, type: :string, description: 'item type slug', required: false

    get("Return a Catalog's SimpleSearch") do
      tags 'SimpleSearch'
      consumes 'application/json'
      security [BearerAuth: []]
      description <<-HTML.squish
        <p><b>Authorization: User+/Member+/Editor+ (according to catalog's visibility)</b></p>
      HTML

      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
        end
      end

      # test catalog authentication
      response(200, 'successful') do
        include_examples "API_KEY_Success", :one
      end

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
