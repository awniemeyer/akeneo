# frozen_string_literal: true

require 'akeneo/image_service'

describe Akeneo::ImageService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#find' do
    let(:image_code) { 'an_image_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/assets/#{image_code}" }
    let(:response_body) { { 'code' => image_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the asset request' do
      service.find(image_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/assets/an_image_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(image_code)

      expect(response).to eq('code' => 'an_image_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(image_code)

        expect(response).to be(nil)
      end
    end
  end

  describe '#download' do
    let(:image_code) { 'an_image_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/assets/#{image_code}/reference-files/no-locale/download" }
    let(:response_body) { 'lol' }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the reference file request' do
      service.download(image_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/assets/an_image_code/reference-files/no-locale/download'
      )
    end

    it 'returns the body base64 encoded' do
      response = service.download(image_code)

      expected = Base64.strict_encode64(response_body)
      expect(response).to eq(expected)
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.download(image_code)

        expect(response).to be(nil)
      end
    end
  end

  describe '#create_asset' do
    let(:code) { 'code' }
    let(:options) { { some: 'option' } }
    let(:body) { 'code' }
    let(:header) { 'code' }

    before do
      stub_request(:post, 'http://akeneo.api/api/rest/v1/assets')
    end

    it 'creates an asset' do
      expected = {
        body: {
          code: code,
          some: 'option'
        }.to_json,
        headers: {
          'Authorization' => 'Bearer access_token',
          'Content-Type' => 'application/json'
        }
      }

      service.create_asset(code, options)

      expect(WebMock).to have_requested(:post, 'http://akeneo.api/api/rest/v1/assets').with(expected)
    end
  end

  describe '#create_reference' do
    let(:code) { 'code' }
    let(:locale) { 'en-GB' }
    let(:file) { 'file' }
    let(:filename) { 'filename' }

    before do
      stub_request(:post, 'https://akeneo.api:80/api/rest/v1/assets/code/reference-files/en-GB')
    end

    it 'creates a reference' do
      service.create_reference(code, locale, file, filename)

      expected_body = [
        '--AwesomeBoundary',
        'Content-Disposition: form-data; name="file"; filename="filename"',
        'Content-Type: []',
        '',
        'file',
        '',
        '--AwesomeBoundary--'
      ]

      expect(WebMock)
        .to have_requested(:post, 'https://akeneo.api:80/api/rest/v1/assets/code/reference-files/en-GB')
          .with { |req| req.headers['Authorization'] == 'Bearer access_token' }
          .with { |req| req.headers['Content-Type'] == 'multipart/form-data; boundary=AwesomeBoundary' }
          .with { |req| blubber(req, expected_body) }
          .with { |req| req.body.split("\r\n") == expected_body }
    end
  end
end
