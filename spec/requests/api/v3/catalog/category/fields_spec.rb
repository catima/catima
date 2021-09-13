# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/item_type/{item_type_id}/fields', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:one_admin) { users(:one_admin) }
  let!(:Authorization) { generate_auth_header(one_admin) }

  let!(:catalog_one) { catalogs(:one) }
  let!(:catalog_id) { catalog_one.id }
  let!(:category) { catalog_one.categories.first }
  let!(:category_id) { category.id }
  let!(:field) { Field.where(field_set_id: category.id).first }
  let!(:field_id) { field.id }

  path '/api/v3/{catalog_id}/category/{category_id}/fields' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'category_id', in: :path, type: :integer, description: 'category_id'

    get("List Category's Fields") do
      tags 'Category'
      consumes 'application/json'
      security [BearerAuth: []]
      description <<-HTML.squish
        <p><b>Authorization: Admin+</b></p>
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
