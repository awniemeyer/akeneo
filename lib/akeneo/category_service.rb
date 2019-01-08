# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class CategoryService < ServiceBase
    def find(code)
      response = get_request("/categories/#{code}")

      response.parsed_response if response.success?
    end
  end
end
