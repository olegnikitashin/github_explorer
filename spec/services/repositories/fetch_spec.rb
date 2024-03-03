# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::Fetch do
  subject(:fetch_service) do
    described_class.new(cache_store: cache_store, client: client, serializer: serializer)
  end

  let(:cache_store) { instance_double(CacheStore) }
  let(:client) { instance_double(GithubApi::Client) }
  let(:serializer) { instance_double(Repositories::Serialize) }
  let(:params) { { query: 'ruby', sort: 'stars' } }
  let(:response) { { 'items' => [{ 'name' => 'rails', 'stargazers_count' => 123_456 }] } }
  let(:serialized_response) { [{ name: 'rails', stars: 123_456 }] }
  let(:cache_key) { 'github_repos:ruby:stars' }

  before do
    allow(cache_store).to receive(:fetch)
      .with(cache_key, expires_in: described_class::CACHE_TTL_IN_SECONDS)
      .and_yield
    allow(client).to receive(:search_repositories)
      .with(params)
      .and_return(response)
    allow(serializer).to receive(:call)
      .with(response)
      .and_return(serialized_response)
  end

  describe '#call' do
    context 'when data is cached' do
      before do
        allow(cache_store).to receive(:fetch)
          .with(cache_key, expires_in: described_class::CACHE_TTL_IN_SECONDS)
          .and_return(serialized_response)
      end

      it 'returns data from the cache without calling the API' do
        expect(client).not_to receive(:search_repositories)
        expect(fetch_service.call(params)).to eq(serialized_response)
      end
    end

    context 'when data is not cached' do
      it 'calls the API and returns serialized response' do
        result = fetch_service.call(params)

        expect(result).to eq(serialized_response)
      end

      it 'caches the new data' do
        fetch_service.call(params)

        expect(cache_store).to have_received(:fetch)
          .with(cache_key, expires_in: described_class::CACHE_TTL_IN_SECONDS)
        expect(client).to have_received(:search_repositories).with(params)
        expect(serializer).to have_received(:call).with(response)
      end
    end
  end
end
