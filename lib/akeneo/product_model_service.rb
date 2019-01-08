# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class ProductModelService < ServiceBase
    def find(id)
      response = get_request("/product-models/#{id}")

      response.parsed_response if response.success?
    end

    def all(with_family: nil)
      Enumerator.new do |product_models|
        path = "/product-models?#{pagination_param}&#{limit_param}"
        path += search_with_family_param(with_family) if with_family

        loop do
          response = get_request(path)
          extract_collection_items(response).each { |product_model| product_models << product_model }
          path = extract_next_page_path(response)
          break unless path
        end
      end
    end

    private

    def search_with_family_param(family)
      "&search={\"family\":[{\"operator\":\"IN\",\"value\":[\"#{family}\"]}]}"
    end
  end
end
