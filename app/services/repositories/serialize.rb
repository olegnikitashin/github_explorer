# frozen_string_literal: true

module Repositories
  class Serialize
    def call(response)
      response['items'].map do |repo|
        {
          name: repo['name'],
          author: repo['owner']['login'],
          url: repo['html_url'],
          stars: repo['stargazers_count']
        }
      end
    end
  end
end
