# frozen_string_literal: true

module GithubApi
  module Exceptions
    class ApiError < StandardError; end
    class BadRequestError < ApiError; end
    class UnauthorizedError < ApiError; end
    class ForbiddenError < ApiError; end
    class NotFoundError < ApiError; end
    class UnprocessableEntityError < ApiError; end
  end
end
