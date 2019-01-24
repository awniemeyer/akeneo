# frozen_string_literal: true

require 'base64'
require 'json'
require 'mime/types'
require 'net/http'
require 'uri'

require_relative './service_base.rb'

module Akeneo
  class ImageService < ServiceBase
    BOUNDARY = 'AwesomeBoundary'

    def find(code)
      response = get_request("/assets/#{code}")

      response.parsed_response if response.success?
    end

    def download(code)
      download_request(code)
    end

    def create_asset(code, options = {})
      body = { code: code }.merge(options)
      post_request('/assets', body.to_json)
    end

    def create_reference(code, locale, file, filename)
      uri = reference_uri(code, locale)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri, reference_header)
      request.body = reference_body(file, filename)
      http.request(request)
    end

    private

    def reference_header
      authorization_headers.merge("Content-Type": "multipart/form-data; boundary=#{BOUNDARY}")
    end

    def reference_body(file, filename)
      body = []
      body << "--#{BOUNDARY}\r\n"
      body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
      body << "Content-Type: #{MIME::Types.type_for(filename)}\r\n\r\n"
      body << file
      body << "\r\n\r\n--#{BOUNDARY}--\r\n"
      body.join
    end

    def reference_uri(code, locale)
      URI.parse("#{@url}/api/rest/v1/assets/#{code}/reference-files/#{locale}")
    end

    def post_request(path, body)
      HTTParty.post(
        "#{@url}/api/rest/v1#{path}",
        headers: default_request_headers,
        body: body
      )
    end

    def download_request(code)
      response = get_request("/assets/#{code}/reference-files/no-locale/download")

      Base64.strict_encode64(response.body) if response.success?
    rescue StandardError => e
      SemanticLogger['AkeneoService#download_image_request'].info("Error downloading file: #{e}")
    end
  end
end
