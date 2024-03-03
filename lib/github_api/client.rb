# frozen_string_literal: true

require 'httparty'
require 'oj'

module GithubApi
  class Client
    include HTTParty

    HTTP_OK_CODE = 200

    base_uri 'https://api.github.com'
    format :json

    attr_reader :access_token

    def initialize(access_token: ENV['GITHUB_ACCESS_TOKEN'])
      @access_token = access_token
    end

    def search_repositories(params = {})
      response = self.class.get(
        '/search/repositories',
        headers: { 'Authorization' => "Bearer #{access_token}" },
        query: {
          q: params[:query],
          sort: params[:sort],
          order: params[:order],
          page: params[:page],
          per_page: params[:per_page]
        }
      )

      return Oj.load(response.body) if response_successful?(response)

      ErrorHandler.call(response)
    end

    private

    def response_successful?(response)
      response.code == HTTP_OK_CODE
    end
  end
end
