# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::Serialize do
  subject(:serialize_service) { described_class.new }

  describe '#call' do
    let(:github_response) { Oj.load(File.read('spec/fixtures/repositories/response_200.json')) }
    let(:expected_output) do
      [
        {
          name: 'awesome-interview-questions',
          author: 'DopplerHQ',
          url: 'https://github.com/DopplerHQ/awesome-interview-questions',
          stars: 65_097
        },
        {
          name: 'rails',
          author: 'rails',
          url: 'https://github.com/rails/rails',
          stars: 54_523
        },
        {
          name: 'jekyll',
          author: 'jekyll',
          url: 'https://github.com/jekyll/jekyll',
          stars: 47_990
        },
        {
          name: 'grpc',
          author: 'grpc',
          url: 'https://github.com/grpc/grpc',
          stars: 40_307
        },
        {
          name: 'discourse',
          author: 'discourse',
          url: 'https://github.com/discourse/discourse',
          stars: 39_945
        }
      ]
    end

    it 'correctly serializes the GitHub API response' do
      expect(serialize_service.call(github_response)).to eq(expected_output)
    end
  end
end
