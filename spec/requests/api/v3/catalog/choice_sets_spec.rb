require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/choice_set(s)', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:two_admin) { users(:two_admin) }
  let!(:Authorization) { generate_auth_header(two_admin) }

  let!(:catalog_two) { catalogs(:two) }
  let!(:catalog_id) { catalog_two.id }

  path '/api/v3/{catalog_id}/choice_sets' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'

    get("List Catalog's ChoiceSets") do
      tags 'Catalog'
      consumes 'application/json'
      security [BearerAuth: []]
      description <<-HTML.squish
        <p><b>Authorization: Admin+</b></p>
      HTML

      response(200, 'successful') do
        run_test! do
          body = response.parsed_body
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
