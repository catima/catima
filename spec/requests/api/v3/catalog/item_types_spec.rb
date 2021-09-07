# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/item_type(s)', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:two_admin) { users(:two_admin) }
  let!(:Authorization) { generate_auth_header(two_admin) }

  let!(:catalog_two) { catalogs(:two) }
  let!(:catalog_id) { catalog_two.id }
  let!(:item_type) { catalog_two.item_types.first }
  let!(:item_type_id) { item_type.id }

  path '/api/v3/{catalog_id}/item_types' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'

    get("List Catalog's ItemTypes") do
      tags 'Catalog'
      consumes 'application/json'
      security [BearerAuth: []]
      description <<-HTML.squish
        <p><b>Authorization: Editor+</b></p>
      HTML

      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
        end
      end

      # test catalog authentication
      response(200, 'successful') do
        include_examples "API_KEY_Success", :two
      end

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end

  path '/api/v3/{catalog_id}/item_type/{item_type_id}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'item_type_id', in: :path, type: :integer, description: 'item_type_id'

    get("Return an ItemType") do
      tags 'ItemType'
      consumes 'application/json'
      security [BearerAuth: []]
      description <<-HTML.squish
        <p><b>Authorization: Editor+</b></p>
      HTML

      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body).to have_key("data")
        end
      end

      # test catalog authentication
      response(200, 'successful') do
        include_examples "API_KEY_Success", :two
      end

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
