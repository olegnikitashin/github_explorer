# frozen_string_literal: true

require 'dry-validation'

module Repositories
  ValidateParams = Dry::Validation.Contract do
    params do
      required(:query).filled(:string)
      optional(:sort).filled(:string, included_in?: %w[stars name])
      optional(:order).filled(:string, included_in?: %w[desc asc])
      optional(:page).filled(:integer, gt?: 0)
      optional(:per_page).filled(:integer, gt?: 0)
    end
  end
end
