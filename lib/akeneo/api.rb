# frozen_string_literal: true

require_relative './services'

module Akeneo
  class API
    include Akeneo::Services

    MASTER_CATEGORY_CODE = 'master'

    attr_accessor :access_token, :url, :last_refresh

    def initialize(url:, client_id:, secret:, username:, password:)
      @url = url
      authorization_service.authorize!(
        client_id: client_id,
        secret: secret,
        username: username,
        password: password
      )
    end

    def fresh_access_token
      authorization_service.fresh_access_token
    end

    def product(sku)
      product_service.find(sku)
    end

    def products(with_family: nil)
      product_service.all(with_family: with_family)
    end

    def published_products(updated_after: nil)
      published_product_service.published_products(updated_after: updated_after)
    end

    def parents(with_family: nil)
      product_model_service.all(with_family: with_family)
    end

    def create_or_update_product(code:, options:)
      product_service.create_or_update(code, options)
    end

    def create_or_update_product_model(code:, options:)
      product_model_service.create_or_update(code, options)
    end

    def product_parent(code)
      product_model_service.find(code)
    end

    def image(code)
      image_service.find(code)
    end

    def upload_image(code:, file:, filename:, options: {})
      locale = options.delete(:locale) || 'no-locale'
      image_service.create_asset(code, options)
      image_service.create_reference(code, locale, file, filename)
    end

    def download_image(code)
      image_service.download(code)
    end

    def product_parent_or_grand_parent(code)
      product_parent = product_model_service.find(code)

      return if product_parent.nil?
      return product_parent unless product_parent['parent']

      product_model_service.find(product_parent['parent'])
    end

    def family(family_code)
      family_service.find(family_code)
    end

    def family_variant(family_code, family_variant_code)
      family_service.variant(family_code, family_variant_code)
    end

    def option_values_of(family_code, family_variant_code)
      family_variant = family_service.variant(family_code, family_variant_code)
      return [] unless family_variant

      [
        find_attribute_code_for_level(family_variant, 1),
        find_attribute_code_for_level(family_variant, 2)
      ].compact
    end

    def brothers_and_sisters(id)
      product_service.brothers_and_sisters(id)
    end

    def attribute(code)
      attribute_service.find(code)
    end

    def attribute_option(code, option_code)
      attribute_service.option(code, option_code)
    end

    def measure_family(code)
      measure_family_service.find(code)
    end

    def category(code)
      category_service.find(code)
    end

    def categories(code, categories: [])
      category = category_service.find(code)

      return [] if category.nil?

      categories << category

      return categories if category['parent'].nil? || category['parent'] == MASTER_CATEGORY_CODE

      categories(category['parent'], categories: categories)
    end

    private

    def find_attribute_code_for_level(family_variant, level)
      family_variant['variant_attribute_sets'].find do |attribute_set|
        attribute_set['level'] == level
      end.to_h['axes'].to_a.first
    end
  end
end
