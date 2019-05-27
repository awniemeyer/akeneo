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

    def search_params(family: nil, completeness: nil, updated_after: nil)
      return '' if family.nil? && completeness.nil? && updated_after.nil?

      "&search=#{search_params_hash(family, completeness, updated_after).to_json}"
    end

    def search_params_hash(family, completeness, updated_after)
      {}.tap do |hash|
        hash[:family] = [{ operator: 'IN', value: [family] }] if family
        hash[:completeness] = [completeness] if completeness
        hash[:updated] = [{ operator: '>', value: updated_after.strftime('%F %T') }] if updated_after
      end
    end

    def json_headers
      { 'Content-Type' => 'application/json' }
    end

    def akeneo_collection_headers
      { 'Content-Type' => 'application/vnd.akeneo.collection+json' }
    end

    def authorization_headers
      { 'Authorization' => "Bearer #{@access_token}" }
    end

    def default_request_headers
      authorization_headers.merge(json_headers)
    end

    def collection_request_headers
      authorization_headers.merge(akeneo_collection_headers)
    end

    def get_request(path, options = {})
      HTTParty.get(
        "#{@url}/api/rest/v1#{path}",
        options.merge(headers: default_request_headers)
      )
    end

    def patch_request(path, options = {})
      HTTParty.patch(
        "#{@url}/api/rest/v1#{path}",
        options.merge(headers: default_request_headers)
      )
    end

    def patch_for_collection_request(path, options = {})
      HTTParty.patch(
        "#{@url}/api/rest/v1#{path}",
        options.merge(headers: collection_request_headers)
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
