# frozen_string_literal: true

require 'akeneo/product_model_service'

describe Akeneo::ProductModelService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#find' do
    let(:product_model_code) { 'product_model_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/product-models/#{product_model_code}" }
    let(:response_body) { { 'code' => product_model_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the product model request' do
      service.find(product_model_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/product-models/product_model_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(product_model_code)

      expect(response).to eq('code' => 'product_model_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(product_model_code)

        expect(response).to be(nil)
      end
    end
  end
  describe '#all' do
    let(:request_url) { 'http://akeneo.api/api/rest/v1/product-models?limit=100&pagination_type=search_after' }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }
    let(:response_body) do
      {
        '_embedded' => {
          'items' => []
        }
      }.to_json
    end

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'requests the first page' do
      product_models = service.all

      product_models.each(&:inspect)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/product-models?limit=100&pagination_type=search_after'
      )
    end

    context 'with next page' do
      let(:next_url) { 'http://akeneo.api/api/rest/v1/next_path' }
      let(:response_body) do
        {
          '_links' => {
            'next' => {
              'href' => next_url
            }
          },
          '_embedded' => {
            'items' => []
          }
        }.to_json
      end

      let(:next_response_body) do
        {
          '_embedded' => {
            'items' => [1]
          }
        }.to_json
      end

      before do
        stub_request(:get, next_url).to_return(
          status: response_status,
          headers: response_headers,
          body: next_response_body
        )
      end

      it 'requests the next page' do
        product_models = service.all

        product_models.each(&:inspect)

        expect(WebMock).to have_requested(
          :get,
          'http://akeneo.api/api/rest/v1/next_path'
        )
      end
    end

    it 'returns an enumerator of product_models' do
      product_models = service.all

      expect(product_models).to be_a(Enumerator)
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns an enumerator with 0 items' do
        product_models = service.all

        expect(product_models.count).to be(0)
      end
    end
  end
end
