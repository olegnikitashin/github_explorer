# frozen_string_literal: true

require 'spec_helper'
require 'oj'

RSpec.describe '/api/v1/search' do
  include Rack::Test::Methods

  def app
    RepositoriesController
  end

  describe 'GET /search' do
    context 'with valid parameters' do
      let(:mock_response) do
        Oj.dump(
          {
            'items' => [
              {
                'name' => 'rails',
                'stargazers_count' => 123_456,
                'owner' => { 'login' => 'rails' },
                'html_url' => 'https://github.com/rails/rails'
              }
            ]
          }
        )
      end
      let(:expected_response) do
        [
          {
            name: 'rails',
            author: 'rails',
            url: 'https://github.com/rails/rails',
            stars: 123_456
          }
        ]
      end

      before do
        allow(RedisConnection).to receive(:client).and_return(MockRedis.new)
        stub_request(:get, 'https://api.github.com/search/repositories')
          .with(
            query: {
              q: 'rails',
              sort: 'stars',
              order: 'desc',
              page: 1,
              per_page: 10
            },
            headers: {
              'Authorization' => /^Bearer .+$/,
              'Accept' => '*/*',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 200, body: mock_response)
      end

      it 'responds with 200 OK and returns search results' do
        get '/api/v1/search', { query: 'rails', sort: 'stars', order: 'desc', page: 1, per_page: 10 }

        expect(last_response.status).to eq(200)
        expect(Oj.load(last_response.body)).to eq(expected_response)
      end
    end

    context 'with invalid parameters' do
      it 'responds with 422 Unprocessable Entity and returns validation errors' do
        get '/api/v1/search', { sort: 'stars', order: 'desc' }

        expect(last_response.status).to eq(422)
        expect(Oj.load(last_response.body)).to eq({ errors: { query: ['is missing'] } })
      end
    end
  end
end
