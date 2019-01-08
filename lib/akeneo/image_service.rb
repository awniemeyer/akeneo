# frozen_string_literal: true

require 'base64'
require 'stringio'

require_relative './service_base.rb'

module Akeneo
  class ImageService < ServiceBase
    def find(code)
      response = get_request("/assets/#{code}")

      response.parsed_response if response.success?
    end

    def download(code)
      download_request(code)
    end

    private

    def download_request(code)
      response = get_request("/assets/#{code}/reference-files/no-locale/download")

      Base64.strict_encode64(response.body) if response.success?
    rescue StandardError => e
      SemanticLogger['AkeneoService#download_image_request'].info("Error downloading file: #{e}")
    end
  end
end
