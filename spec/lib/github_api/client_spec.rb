# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GithubApi::Client do
  include WebMock::API

  subject(:client) { described_class.new(access_token: access_token) }

  let(:access_token) { 'test_access_token' }
  let(:headers) { { 'Authorization' => "Bearer #{access_token}" } }

  describe '#search_repositories' do
    context 'when the request is successful' do
      let(:github_response) { File.read('spec/fixtures/repositories/response_200.json') }

      before do
        stub_request(:get, 'https://api.github.com/search/repositories')
          .with(
            query:
              {
                q: 'rails',
                sort: 'stars',
                order: 'desc',
                page: 1,
                per_page: 10
              },
            headers: headers
          )
          .to_return(status: 200, body: github_response)
      end

      let(:params) { { query: 'rails', sort: 'stars', order: 'desc', page: 1, per_page: 10 } }

      it 'fetches repositories from GitHub' do
        response = client.search_repositories(params)

        expect(response).to eq(Oj.load(github_response))
      end
    end

    context 'when the request is unsuccessful' do
      let(:github_response) { File.read('spec/fixtures/repositories/response_422.json') }

      before do
        stub_request(:get, 'https://api.github.com/search/repositories')
          .with(
            query:
              {
                q: '',
                sort: 'stars',
                order: 'desc',
                page: 1,
                per_page: 10
              },
            headers: headers
          )
          .to_return(status: 422, body: github_response)
      end

      let(:params) { { sort: 'stars', order: 'desc', page: 1, per_page: 10 } }

      it 'handles the error response' do
        expect { client.search_repositories(params) }.to raise_error(
          GithubApi::Exceptions::UnprocessableEntityError
        )
      end
    end
  end
end
