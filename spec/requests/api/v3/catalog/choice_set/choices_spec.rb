# rubocop:disable Metrics/BlockLength
require 'swagger_helper'

RSpec.describe 'api/v3/{catalog_id}/choice_set/{choice_set_id}/choice(s)', type: :request do
  fixtures :all

  let(:locale) { 'fr' }
  let!(:two_admin) { users(:two_admin) }
  let!(:Authorization) { generate_auth_header(two_admin) }

  let!(:catalog_two) { catalogs(:two) }
  let!(:catalog_id) { catalog_two.id }
  let!(:choice) { choices(:two_english_us_redneck_mode) }
  let!(:choice_id) { choice.id }
  let!(:choice_set) { choice.choice_set }
  let!(:choice_set_id) { choice_set.id }

  path '/api/v3/{catalog_id}/choice_set/{choice_set_id}/choices' do
    parameter name: 'page', in: :query, type: :integer, description: 'page number', default: 1, required: false
    parameter name: 'per', in: :query, type: :integer, description: 'records number per page', default: 25, required: false
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'choice_set_id', in: :path, type: :integer, description: 'choice_set_id'

    get("List ChoiceSet's Choices") do
      tags 'ChoiceSet'
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

  path '/api/v3/{catalog_id}/choice_set/{choice_set_id}/choice/{choice_id}' do
    parameter name: 'catalog_id', in: :path, type: :integer, description: 'catalog_id'
    parameter name: 'choice_set_id', in: :path, type: :integer, description: 'choice_set_id'
    parameter name: 'choice_id', in: :path, type: :integer, description: 'choice_id'

    get("Return an ChoiceSet's Choice") do
      tags 'Choice'
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
