# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/item_type/{item_type_id}/field(s)', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:one_admin) { users(:one_admin) }
  let!(:Authorization) { generate_auth_header(one_admin) }

  let!(:catalog_one) { catalogs(:one) }
  let!(:catalog_id) { catalog_one.id }
  let!(:item_type) { catalog_one.item_types.second }
  let!(:item_type_id) { item_type.id }
  let!(:field) { Field.where(field_set_id: item_type.id).first }
  let!(:field_id) { field.id }

  path '/api/v3/{catalog_id}/item_type/{item_type_id}/fields' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'item_type_id', in: :path, type: :integer, description: 'item_type_id'

    get("List ItemType's Fields") do
      tags 'ItemType'
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

  path '/api/v3/{catalog_id}/item_type/{item_type_id}/field/{field_id}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'item_type_id', in: :path, type: :integer, description: 'item_type_id'
    parameter name: 'field_id', in: :path, type: :integer, description: 'field_id'

    get("Return an ItemType's Field") do
      tags 'Field'
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
# rubocop:enable Metrics/BlockLength
