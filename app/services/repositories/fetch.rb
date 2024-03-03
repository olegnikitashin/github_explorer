# frozen_string_literal: true

module Repositories
  class Fetch
    CACHE_TTL_IN_SECONDS = 3600

    def initialize(
      cache_store: CacheStore.new,
      client: GithubApi::Client.new,
      serializer: Serialize.new
    )
      @cache_store = cache_store
      @client = client
      @serializer = serializer
    end

    def call(params)
      @cache_store.fetch(cache_key(params), expires_in: CACHE_TTL_IN_SECONDS) do
        response = @client.search_repositories(params)

        @serializer.call(response)
      end
    end

    private

    def cache_key(params)
      "github_repos:#{params.values.join(':')}"
    end
  end
end
