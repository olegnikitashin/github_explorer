# frozen_string_literal: true

require 'redis'

class RedisConnection
  def self.client
    @client ||= Redis.new(url: ENV['REDIS_URL'])
  end
end
