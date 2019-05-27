# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class ProductService < ServiceBase
    def initialize(url:, access_token:, product_model_service:, family_service:)
      @url = url
      @access_token = access_token
      @product_model_service = product_model_service
      @family_service = family_service
    end

    def find(id)
      response = get_request("/products/#{id}")

      response.parsed_response if response.success?
    end

    def brothers_and_sisters(id)
      akeneo_product = find(id)
      akeneo_parent = load_akeneo_parent(akeneo_product['parent'])
      akeneo_grand_parent = load_akeneo_parent(akeneo_parent['parent']) unless akeneo_parent.nil?

      parents = load_parents(akeneo_product['family'], akeneo_parent, akeneo_grand_parent)

      load_products(akeneo_product, akeneo_product['family'], parents)
    end

    def all(with_family: nil, with_completeness: nil, updated_after: nil)
      Enumerator.new do |products|
        path = build_path(with_family, with_completeness, updated_after)

        loop do
          response = get_request(path)
          extract_collection_items(response).each { |product| products << product }
          path = extract_next_page_path(response)
          break unless path
        end
      end
    end

    def create_or_update(code, options)
      patch_request("/products/#{code}", body: options.to_json)
    end

    def create_several(product_objects)
      patch_for_collection_request('/products', body: product_objects.to_json)
    end

    private

    def build_path(family, completeness, updated_after)
      path = "/products?#{pagination_param}&#{limit_param}"
      path + search_params(
        family: family,
        completeness: completeness,
        updated_after: updated_after
      )
    end

    def load_akeneo_parent(code)
      return unless code

      @product_model_service.find(code)
    end

    def load_parents(family, akeneo_parent, akeneo_grand_parent)
      return [] if akeneo_parent.nil?
      return [akeneo_parent] if akeneo_grand_parent.nil?

      @product_model_service.all(with_family: family).select do |parent|
        parent['parent'] == akeneo_grand_parent['code']
      end
    end

    def load_products(akeneo_product, family, parents)
      return [akeneo_product] if parents.empty?

      products = all(with_family: family)
      parent_codes = parents.map { |parent| parent['code'] }

      products.select do |product|
        parent_codes.include?(product['parent'])
      end.flatten
    end

    def find_product_image_level(family, family_variant)
      family_variant = @family_service.variant(family, family_variant)

      product_image_attribute_set = family_variant['variant_attribute_sets'].find do |attribute_set|
        attribute_set['attributes'].include?('product_images')
      end

      return 0 unless product_image_attribute_set

      product_image_attribute_set.fetch('level', 0)
    end
  end
end
