# frozen_string_literal: true

require 'dry-struct'

module Repositories
  class PrepareParams < Dry::Struct
    include Dry::Types()

    attribute :query, String
    attribute :sort, String.default('stars')
    attribute :order, String.default('desc')
    attribute :page, Integer.default(1)
    attribute :per_page, Integer.default(30)
  end
end
