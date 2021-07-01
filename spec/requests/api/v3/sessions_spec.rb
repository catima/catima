require 'swagger_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'api/v3/sessions', type: :request do
  fixtures :all

  let!(:user) { users(:system_admin) }
  let!(:Authorization) { generate_auth_header(user) }
  let!(:api_v3_user) do
    {
      api_v3_user: {
        email: user.email,
        password: "password"
      }
    }
  end

  path '/api/v3/login' do
    post('Create Session') do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :api_v3_user, in: :body, schema: {'$ref' => '#/components/schemas/api_v3_user'}

      response(200, 'authentication_success') do
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to have_key("token")
          expect(body).to have_key("valid_until")
          expect(body).to have_key("message")
          expect(body).to have_key("code")
          expect(body["message"]).to eq("Authentication successful")
          expect(body["code"]).to eq("authentication_success")
        end
      end

      response(401, 'authentication_error') do
        let!(:api_v3_user) {}

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to have_key("message")
          expect(body).to have_key("code")
          expect(body["message"]).to eq("Authentication error")
          expect(body["code"]).to eq("authentication_error")
        end
      end
    end
  end

  path '/api/v3/logout' do
    delete('Delete Session') do
      tags 'Authentication'
      consumes 'application/json'
      security [BearerAuth: []]

      response(200, 'successful') do
        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a valid 200 response', skip_after: true do
          expect(response.code).to eq("200")
        end
      end
    end
  end
end
