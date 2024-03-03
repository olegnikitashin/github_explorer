# frozen_string_literal: true

require 'redis'
require 'oj'

class CacheStore
  DEFAULT_TTL_IN_SECONDS = 3600

  def initialize(redis_client: RedisConnection.client)
    @redis_client = redis_client
  end

  def fetch(key, expires_in: DEFAULT_TTL_IN_SECONDS)
    cached_value = @redis_client.get(key)
    return Oj.load(cached_value) if cached_value

    result = yield
    @redis_client.set(key, Oj.dump(result), ex: expires_in) if result
    result
  rescue Redis::BaseError => e
    AppLogger.logger.error "Redis error: #{e.message}"
    yield
  end
end
