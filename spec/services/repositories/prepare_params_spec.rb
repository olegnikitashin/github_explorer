# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::PrepareParams do
  subject(:prepare_params_service) { described_class.new(params) }

  describe 'with default parameters' do
    let(:params) { { query: 'rails' } }

    it 'applies default values' do
      expect(prepare_params_service.query).to eq('rails')
      expect(prepare_params_service.sort).to eq('stars')
      expect(prepare_params_service.order).to eq('desc')
      expect(prepare_params_service.page).to eq(1)
      expect(prepare_params_service.per_page).to eq(30)
    end
  end

  describe 'with custom parameters' do
    let(:params) do
      {
        query: 'rails',
        sort: 'name',
        order: 'asc',
        page: 2,
        per_page: 10
      }
    end

    it 'accepts custom values' do
      expect(prepare_params_service.query).to eq('rails')
      expect(prepare_params_service.sort).to eq('name')
      expect(prepare_params_service.order).to eq('asc')
      expect(prepare_params_service.page).to eq(2)
      expect(prepare_params_service.per_page).to eq(10)
    end
  end
end
