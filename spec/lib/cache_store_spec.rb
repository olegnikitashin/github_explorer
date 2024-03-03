# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CacheStore do
  subject(:cache_store) { described_class.new }

  let(:redis_client) { instance_double(Redis) }
  let(:cache_key) { 'test_key' }
  let(:cache_value) { { some: 'data' } }
  let(:serialized_value) { Oj.dump(cache_value) }

  before do
    allow(RedisConnection).to receive(:client).and_return(redis_client)
  end

  describe '#fetch' do
    context 'when data is already cached' do
      before do
        allow(redis_client).to receive(:get).with(cache_key).and_return(serialized_value)
      end

      it 'returns the cached data without calling the block' do
        expect { |b| cache_store.fetch(cache_key, &b) }.not_to yield_control
        expect(cache_store.fetch(cache_key)).to eq(cache_value)
      end
    end

    context 'when data is not cached' do
      before do
        allow(redis_client).to receive(:get).with(cache_key).and_return(nil)
        allow(redis_client).to receive(:set).with(
          cache_key,
          serialized_value,
          ex: CacheStore::DEFAULT_TTL_IN_SECONDS
        )
      end

      it 'calls the block and caches its result' do
        result = cache_store.fetch(cache_key) { cache_value }

        expect(result).to eq(cache_value)
        expect(redis_client).to have_received(:set).with(
          cache_key,
          serialized_value,
          ex: CacheStore::DEFAULT_TTL_IN_SECONDS
        )
      end
    end

    context 'when a Redis error occurs' do
      before do
        allow(redis_client).to receive(:get).with(anything).and_raise(Redis::ConnectionError.new('Redis error'))
        allow(AppLogger.logger).to receive(:error)
      end

      it 'logs the error and calls the block' do
        expect { |b| cache_store.fetch(cache_key, &b) }.to yield_control
        expect(AppLogger.logger).to have_received(:error).with(/Redis error/)
      end
    end
  end
end
