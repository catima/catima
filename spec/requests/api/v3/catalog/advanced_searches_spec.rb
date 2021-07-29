# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/advanced_search', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:one_admin) { users(:one_admin) }
  let!(:Authorization) { generate_auth_header(one_admin) }

  let!(:catalog_one) { catalogs(:one) }
  let!(:catalog_id) { catalog_one.id }
  let!(:item) { items(:one_author_stephen_king) }
  let!(:item_id) { item.id }
  let!(:item_type) { item.item_type }
  let!(:item_type_id) { item_type.id }
  let!(:uuid) { 'MyString' }
  let!(:advanced_search) do
    {
      advanced_search: {
        criteria: {
          "#{item_type.items.first.fields.first.uuid.to_sym}": {
            field_condition: 'and',
            condition: 'one_word',
            value: 'query'
          }
        }
      }
    }
  end

  path '/api/v3/{catalog_id}/advanced_search/{item_type_id}/new' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'item_type_id', in: :path, type: :integer, description: 'item_type_id'

    get("Get a Catalog's ItemType AdvancedSearch parmeters") do
      tags 'AdvancedSearch'
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

  path '/api/v3/{catalog_id}/advanced_search/{item_type_id}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'item_type_id', in: :path, type: :integer, description: 'item_type_id'

    post("Create a AdvancedSearch in a Catalog") do
      tags 'AdvancedSearch'
      consumes 'application/json'
      security [BearerAuth: []]

      parameter name: :advanced_search, in: :body, schema: {
        type: :object,
        properties: {
          advanced_search: {
            type: :object,
            properties: {
              criteria: {
                type: :object
                # properties: {
                #   __field_uuid: {
                #     index: {
                #       field_condition
                #       all_words / default
                #       condition
                #       filter_field_uuid
                #     }
                #   }
                # }
              }
            }
          },
          advanced_search_conf: { type: :string, description: '' }
        },
        required: ['advanced_search']
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

  path '/api/v3/{catalog_id}/advanced_search/{uuid}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'uuid', in: :path, type: :string, description: 'search uuid'

    get("Return a Catalog's AdvancedSearch") do
      tags 'AdvancedSearch'
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
