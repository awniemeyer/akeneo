# frozen_string_literal: true

require_relative './attribute_service'
require_relative './authorization_service'
require_relative './category_service'
require_relative './family_service'
require_relative './image_service'
require_relative './measure_family_service'
require_relative './product_model_service'
require_relative './product_service'
require_relative './published_product_service'

module Akeneo
  module Services
    def authorization_service
      @authorization_service ||= AuthorizationService.new(url: url)
    end

    def attribute_service
      AttributeService.new(url: url, access_token: fresh_access_token)
    end

    def category_service
      CategoryService.new(url: url, access_token: fresh_access_token)
    end

    def family_service
      FamilyService.new(url: url, access_token: fresh_access_token)
    end

    def image_service
      ImageService.new(url: url, access_token: fresh_access_token)
    end

    def measure_family_service
      MeasureFamilyService.new(url: url, access_token: fresh_access_token)
    end

    def product_service
      ProductService.new(
        url: url,
        access_token: fresh_access_token,
        product_model_service: product_model_service,
        family_service: family_service
      )
    end

    def product_model_service
      ProductModelService.new(url: url, access_token: fresh_access_token)
    end

    def published_product_service
      PublishedProductService.new(url: url, access_token: fresh_access_token)
    end
  end
end
