# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class MeasureFamilyService < ServiceBase
    def find(code)
      response = get_request("/measure-families/#{code}")

      response.parsed_response if response.success?
    end
  end
end
