# frozen_string_literal: true

require 'akeneo/published_product_service'

describe Akeneo::PublishedProductService do
  describe '#published_products' do
    let(:url) { 'http://akeneo.api' }
    let(:access_token) { 'access_token' }
    let(:service) { described_class.new(url: url, access_token: access_token) }
    let(:product) { 'a_product' }
    let(:request_url) { 'http://akeneo.api/api/rest/v1/published-products?pagination_type=search_after' }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }
    let(:response_body) do
      {
        '_embedded' => {
          'items' => [product]
        }
      }.to_json
    end
    let(:response_status) { 200 }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the request lazily' do
      response = service.published_products

      expect(WebMock).not_to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/published-products?pagination_type=search_after'
      )

      response.first

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/published-products?pagination_type=search_after'
      )
    end

    it 'fetches the first page of published products' do
      response = service.published_products

      expect(response.first).to eq('a_product')
    end

    context 'with updated_after parameter' do
      let(:request_url) do
        %w[
          http://akeneo.api/api/rest/v1/published-products
          ?pagination_type=search_after
          &search=%7B%22updated%22:%5B%7B%22operator%22:%22%3E%22,%22value%22:%222018-10-11%2001:00:00%22%7D%5D%7D
        ].join
      end
      let(:last_sync_at) { Time.new(2018, 10, 11, 1, 0) }

      it 'adds the serach queary parameter' do
        service.published_products(updated_after: last_sync_at).first

        expect(WebMock).to have_requested(
          :get,
          %w[
            http://akeneo.api/api/rest/v1/published-products
            ?pagination_type=search_after
            &search=%7B%22updated%22:%5B%7B%22operator%22:%22%3E%22,%22value%22:%222018-10-11%2001:00:00%22%7D%5D%7D
          ].join
        )
      end
    end

    context 'with next link provided in the response' do
      let(:next_url) { 'http://akeneo.api/api/rest/v1/published-products/next_url' }

      let(:response_body) do
        {
          '_links' => {
            'next' => { 'href' => next_url }
          },
          '_embedded' => {
            'items' => [product]
          }
        }.to_json
      end

      let(:second_response_body) do
        {
          '_embedded' => {
            'items' => []
          }
        }.to_json
      end

      before do
        stub_request(:get, next_url).to_return(
          status: response_status,
          headers: response_headers,
          body: second_response_body
        )
      end

      it 'lazy loads the next page' do
        service.published_products.each(&:class)

        expect(WebMock).to have_requested(
          :get,
          'http://akeneo.api/api/rest/v1/published-products/next_url'
        )
      end
    end
  end
end
