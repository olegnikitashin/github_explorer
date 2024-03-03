# frozen_string_literal: true

module GithubApi
  class ErrorHandler
    ERROR_MAP = {
      400 => Exceptions::BadRequestError,
      401 => Exceptions::UnauthorizedError,
      403 => Exceptions::ForbiddenError,
      404 => Exceptions::NotFoundError,
      422 => Exceptions::UnprocessableEntityError
    }.freeze

    def self.call(response)
      error_class = ERROR_MAP[response.code] || Exceptions::ApiError
      raise error_class, "Code: #{response.code}, response: #{response.body}"
    end
  end
end
