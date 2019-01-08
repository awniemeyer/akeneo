# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class FamilyService < ServiceBase
    def find(code)
      response = get_request("/families/#{code}")

      response.parsed_response if response.success?
    end

    def variant(code, variant_code)
      response = get_request("/families/#{code}/variants/#{variant_code}")

      response.parsed_response if response.success?
    end
  end
end
