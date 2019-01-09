# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class PublishedProductService < ServiceBase
    def initialize(url:, access_token:)
      @url = url
      @access_token = access_token
    end

    def published_products(updated_after: nil)
      Enumerator.new do |products|
        path = "/published-products?#{pagination_param}"
        path += "&#{search_param(updated_after)}" if updated_after

        loop do
          response = get_request(path)
          extract_products(response).each { |product| products << product }
          path = extract_next_page_path(response)
          break unless path
        end
      end.lazy
    end

    private

    def search_param(updated_after)
      return unless updated_after

      format('search={"updated":[{"operator":">","value":"%<date>s"}]}', date: updated_after.strftime('%F %T'))
    end

    def extract_products(response)
      return [] unless response.success?

      response.parsed_response['_embedded']['items']
    end
  end
end
