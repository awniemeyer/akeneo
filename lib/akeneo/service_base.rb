# frozen_string_literal: true

require 'httparty'
require 'semantic_logger'

require_relative './cache'

module Akeneo
  class ServiceBase
    prepend Cache

    DEFAULT_PAGINATION_TYPE = :search_after
    DEFAULT_PAGINATION_LIMIT = 100

    def initialize(url:, access_token:)
      @url = url
      @access_token = access_token
    end

    private

    def json_headers
      { 'Content-Type' => 'application/json' }
    end

    def default_request_headers
      { 'Authorization' => "Bearer #{@access_token}" }.merge(json_headers)
    end

    def get_request(path, options = {})
      HTTParty.get(
        "#{@url}/api/rest/v1#{path}",
        options.merge(headers: default_request_headers)
      )
    end

    def pagination_param
      "pagination_type=#{DEFAULT_PAGINATION_TYPE}"
    end

    def limit_param
      "limit=#{DEFAULT_PAGINATION_LIMIT}"
    end

    def extract_collection_items(response)
      return [] unless response.success?

      response.parsed_response['_embedded']['items']
    end

    def extract_next_page_path(response)
      return unless response.success?

      url = response.parsed_response.dig('_links', 'next', 'href')
      url.to_s.split('/api/rest/v1').last
    end
  end
end
