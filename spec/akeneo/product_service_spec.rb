# frozen_string_literal: true

require 'akeneo/product_service'
require 'akeneo/product_model_service'
require 'akeneo/family_service'

describe Akeneo::ProductService do
  let(:url) { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:product_model_service) { instance_double(Akeneo::ProductModelService) }
  let(:family_service) { instance_double(Akeneo::FamilyService) }
  let(:service) do
    described_class.new(
      url: url,
      access_token: access_token,
      product_model_service: product_model_service,
      family_service: family_service
    )
  end

  describe '#find' do
    let(:product_sku) { 'a_product' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/products/#{product_sku}" }
    let(:response_body) { { 'identifier' => product_sku }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the family request' do
      service.find(product_sku)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/products/a_product'
      )
    end

    it 'it returns the response body' do
      response = service.find(product_sku)

      expect(response).to eq('identifier' => 'a_product')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(product_sku)

        expect(response).to be(nil)
      end
    end
  end

  describe '#brothers_and_sisters' do
    let(:product_id) { 42 }

    let(:product) do
      {
        'identifier' => product_id,
        'family' => 'fam',
        'parent' => nil
      }
    end

    before do
      allow(service).to receive(:find) { product }
    end

    it 'requests the akeneo product' do
      service.brothers_and_sisters(product_id)

      expect(service).to have_received(:find).with(42)
    end

    it 'returns only the brother and sisterless product' do
      actual = service.brothers_and_sisters(product_id)
      expected = [product]

      expect(actual).to eql(expected)
    end

    context 'the product has a parent' do
      let(:parent_code) { 'a_parent_code' }
      let(:family) { 'family_code' }
      let(:product) do
        {
          'identifier' => product_id,
          'family' => family,
          'parent' => parent_code
        }
      end
      let(:parent) do
        {
          'code' => parent_code,
          'parent' => nil
        }
      end

      before do
        allow(product_model_service).to receive(:find).and_return(parent)
      end

      it 'requests the akeneo parent' do
        service.brothers_and_sisters(product_id)

        expect(product_model_service).to have_received(:find).with(parent_code)
      end

      it 'returns only the product, is this right @schnika?' do
        actual = service.brothers_and_sisters(product_id)
        expected = [product]

        expect(actual).to eql(expected)
      end
    end

    context 'the parent has a parent itself' do
      let(:product) do
        {
          'identifier' => product_id,
          'family' => 'family_code',
          'parent' => 'parent_code'
        }
      end
      let(:sister_product) do
        {
          'identifier' => 'sister_product_id',
          'family' => 'family_code',
          'parent' => 'parent_code'
        }
      end
      let(:cousin_product) do
        {
          'identifier' => 'sister_product_id',
          'family' => 'family_code',
          'parent' => 'uncle_code'
        }
      end
      let(:product_from_same_family_with_different_parent) do
        {
          'identifier' => 404,
          'family' => 'family_code',
          'parent' => 'different_parent_code'
        }
      end
      let(:parent) do
        {
          'code' => 'parent_code',
          'parent' => 'grand_parent_code'
        }
      end
      let(:uncle) do
        {
          'code' => 'uncle_code',
          'parent' => 'grand_parent_code'
        }
      end
      let(:grand_parent) do
        {
          'code' => 'grand_parent_code',
          'parent' => nil
        }
      end
      let(:all_products_from_family) do
        [
          product,
          sister_product,
          cousin_product,
          product_from_same_family_with_different_parent
        ]
      end
      let(:all_parents_from_family) { [grand_parent, parent, uncle] }

      before do
        allow(product_model_service).to receive(:find).and_return(parent, grand_parent)
        allow(product_model_service).to receive(:all) { all_parents_from_family }
        allow(service).to receive(:all) { all_products_from_family }
      end

      it 'requests the akeneo parent of the parent' do
        service.brothers_and_sisters(product_id)

        expect(product_model_service).to have_received(:find).once.with('parent_code')
        expect(product_model_service).to have_received(:find).once.with('grand_parent_code')
      end

      it 'loads all the parents with the same family' do
        service.brothers_and_sisters(product_id)

        expect(product_model_service).to have_received(:all).with(with_family: 'family_code')
      end

      it 'loads the products with the same family' do
        service.brothers_and_sisters(product_id)

        expect(service).to have_received(:all).with(with_family: 'family_code')
      end

      it 'returns the product with brothers and sisters' do
        actual = service.brothers_and_sisters(product_id)
        expected = [product, sister_product, cousin_product]

        expect(actual).to eql(expected)
      end
    end
  end

  describe '#all' do
    let(:product_sku) { 'a_product' }
    let(:request_url) { 'http://akeneo.api/api/rest/v1/products?limit=100&pagination_type=search_after' }
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
      products = service.all

      products.each(&:inspect)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/products?limit=100&pagination_type=search_after'
      )
    end

    context 'with next page' do
      let(:next_url) { 'http://akeneo.api/api/rest/v1/products/next_url' }
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
        products = service.all

        products.each(&:inspect)

        expect(WebMock).to have_requested(
          :get,
          'http://akeneo.api/api/rest/v1/products/next_url'
        )
      end
    end

    it 'returns an enumerator of products' do
      products = service.all

      expect(products).to be_a(Enumerator)
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns an enumerator with 0 items' do
        products = service.all

        expect(products.count).to be(0)
      end
    end
  end
end
