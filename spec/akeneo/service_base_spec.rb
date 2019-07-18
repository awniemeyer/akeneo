# frozen_string_literal: true

require 'akeneo/service_base'

describe Akeneo::ServiceBase do
  let(:url) { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }

  class AkeneoTestService < described_class
    def find(code)
      get_request("/test_path/#{code}")
    end
  end

  describe '#get_request' do
    let(:service) do
      AkeneoTestService.new(url: 'url', access_token: 'token')
    end

    let(:expected_http_headers) do
      {
        'Authorization' => 'Bearer token',
        'Content-Type' => 'application/json'
      }
    end

    before do
      allow(HTTParty).to receive(:get)
    end

    it 'perfoms a http get request' do
      service.find('a_code')

      expect(HTTParty).to have_received(:get).with(
        'url/api/rest/v1/test_path/a_code',
        headers: expected_http_headers
      )
    end

    it 'escapes the provided path' do
      service.find('a code')

      expect(HTTParty).to have_received(:get).with(
        'url/api/rest/v1/test_path/a%20code',
        headers: expected_http_headers
      )
    end
  end

  describe 'mixins' do
    it 'prepends the Cache module before the ServiceBase' do
      service_base_index = described_class.ancestors.index { |a| a == described_class }
      cache_index = described_class.ancestors.index { |a| a == Akeneo::Cache }

      expect(service_base_index > cache_index).to be(true)
    end
  end
end
