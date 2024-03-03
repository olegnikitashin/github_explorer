# frozen_string_literal: true

require 'rack/attack'
require 'redis'

Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(RedisConnection.client)
Rack::Attack.throttle('requests by ip', limit: 30, period: 60, &:ip)
Rack::Attack.throttled_responder = lambda do |_env|
  [
    429,
    { 'content-type' => 'application/json' },
    [{ errors: 'Too Many Requests. Please retry later.' }.to_json]
  ]
end
