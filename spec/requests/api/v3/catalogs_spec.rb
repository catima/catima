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

      response(401, 'Unauthorized') do
        include_examples "Unauthorized"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
