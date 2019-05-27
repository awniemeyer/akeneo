# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class AttributeService < ServiceBase
    def all
      Enumerator.new do |attributes|
        request_url = "/attributes?#{limit_param}"

        loop do
          response = get_request(request_url)
          extract_collection_items(response).each { |attribute| attributes << attribute }
          request_url = extract_next_page_path(response)
          break unless request_url
        end
      end
    end

    def find(code)
      response = get_request("/attributes/#{code}")

      response.parsed_response if response.success?
    end

    def options(attribute_code)
      response = get_request("/attributes/#{attribute_code}/options")

      response.parsed_response if response.success?
    end

    def option(code, option_code)
      response = get_request("/attributes/#{code}/options/#{option_code}")

      response.parsed_response if response.success?
    end
  end
end
