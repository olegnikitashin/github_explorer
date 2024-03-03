# frozen_string_literal: true

require 'rack/attack'
require 'oj'

class RepositoriesController < Sinatra::Base
  use Rack::Attack

  before do
    request.env['rack.logger'] = AppLogger.logger
    content_type :json
  end

  helpers do
    def logger
      request.env['rack.logger']
    end
  end

  get '/api/v1/search' do
    validation_result = Repositories::ValidateParams.call(request.params)

    if validation_result.success?
      structured_params = Repositories::PrepareParams.new(validation_result.to_h)
      response = Oj.dump(Repositories::Fetch.new.call(structured_params.to_h))

      status 200
    else
      response = Oj.dump(errors: validation_result.errors.to_h)

      status 422
    end

    body response
  end
end
