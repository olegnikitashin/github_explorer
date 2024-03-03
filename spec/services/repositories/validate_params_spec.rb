# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::ValidateParams do
  subject(:validate_params_service) { described_class }

  context 'with valid parameters' do
    let(:valid_params) do
      {
        query: 'rails',
        sort: 'stars',
        order: 'asc',
        page: 1,
        per_page: 10
      }
    end

    it 'passes validation' do
      result = validate_params_service.call(valid_params)

      expect(result).to be_success
      expect(result.errors).to be_empty
    end
  end

  context 'with only required parameters' do
    let(:params_only_required) do
      { query: 'rails' }
    end

    it 'passes validation' do
      result = validate_params_service.call(params_only_required)

      expect(result).to be_success
      expect(result.errors).to be_empty
    end
  end

  context 'with missing query' do
    let(:params_without_query) do
      {
        sort: 'stars',
        order: 'asc',
        page: 1,
        per_page: 10
      }
    end

    it 'fails validation' do
      result = validate_params_service.call(params_without_query)

      expect(result).not_to be_success
      expect(result.errors.to_h).to have_key(:query)
    end
  end

  context 'with invalid sort value' do
    let(:params_with_invalid_sort) do
      {
        query: 'rails',
        sort: 'invalid',
        page: 1,
        per_page: 10
      }
    end

    it 'fails validation' do
      result = validate_params_service.call(params_with_invalid_sort)

      expect(result).not_to be_success
      expect(result.errors.to_h).to have_key(:sort)
    end
  end

  context 'with invalid order value' do
    let(:params_with_invalid_order) do
      {
        query: 'rails',
        sort: 'stars',
        order: 'invalid',
        page: 1,
        per_page: 10
      }
    end

    it 'fails validation' do
      result = validate_params_service.call(params_with_invalid_order)

      expect(result).not_to be_success
      expect(result.errors.to_h).to have_key(:order)
    end
  end

  context 'with invalid page value' do
    let(:params_with_invalid_page) do
      {
        query: 'rails',
        sort: 'stars',
        order: 'asc',
        page: 0,
        per_page: 10
      }
    end

    it 'fails validation' do
      result = validate_params_service.call(params_with_invalid_page)

      expect(result).not_to be_success
      expect(result.errors.to_h).to have_key(:page)
    end
  end

  context 'with invalid per_page value' do
    let(:params_with_invalid_per_page) do
      {
        query: 'rails',
        sort: 'stars',
        order: 'asc',
        page: 1,
        per_page: 0
      }
    end

    it 'fails validation' do
      result = validate_params_service.call(params_with_invalid_per_page)

      expect(result).not_to be_success
      expect(result.errors.to_h).to have_key(:per_page)
    end
  end
end
