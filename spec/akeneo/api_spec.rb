# frozen_string_literal: true

require 'akeneo/api'

describe Akeneo::API do
  let(:headers)      { { 'Content-Type' => 'application/json' } }
  let(:url)          { 'http://akeneo.api' }
  let(:client_id)    { 'client_id' }
  let(:password)     { 'password' }
  let(:secret)       { 'secret' }
  let(:username)     { 'username' }
  let(:access_token) { 'NzFiYTM4ZTEwMjcwZTcyZWIzZTA0NmY3NjE3MTIyMjM1Y2NlMmNlNWEyMTAzY2UzYmY0YWIxYmUzNTkyMDcyNQ' }
  let(:service) do
    described_class.new(
      url: url,
      client_id: client_id,
      password: password,
      secret: secret,
      username: username
    )
  end
  let(:authorization_service) { instance_double(Akeneo::AuthorizationService) }
  before do
    allow(Akeneo::AuthorizationService).to receive(:new) { authorization_service }
    allow(authorization_service).to receive(:authorize!)
    allow(authorization_service).to receive(:fresh_access_token) { access_token }
  end

  describe '#new' do
    it 'creates an authorization service' do
      service

      expect(Akeneo::AuthorizationService).to have_received(:new).with(url: url)
    end

    it 'authorizes' do
      service

      expected = {
        client_id: client_id,
        secret: secret,
        username: username,
        password: password
      }
      expect(authorization_service).to have_received(:authorize!).with(expected)
    end
  end

  describe '#product' do
    let(:product_service) { double(:product_service) }
    let(:product_model_service) { double(:product_model_service) }
    let(:family_service) { double(:family_service) }
    let(:product_id) { 42 }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductService).to receive(:new) { product_service }
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(product_service).to receive(:find)
    end

    it 'initializes a product service' do
      service.product(product_id)

      expect(Akeneo::ProductService).to have_received(:new).with(
        url: url,
        access_token: access_token,
        product_model_service: product_model_service,
        family_service: family_service
      )
    end

    it 'calls find on the service' do
      service.product(product_id)

      expect(product_service).to have_received(:find).with(42)
    end
  end

  describe '#products' do
    let(:product_service) { double(:product_service) }
    let(:product_model_service) { double(:product_model_service) }
    let(:family_service) { double(:family_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductService).to receive(:new) { product_service }
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(product_service).to receive(:all)
    end

    it 'initializes a product service' do
      service.products

      expect(Akeneo::ProductService).to have_received(:new).with(
        url: url,
        access_token: access_token,
        product_model_service: product_model_service,
        family_service: family_service
      )
    end

    it 'calls all on the service' do
      service.products

      expected = { with_family: nil, with_completeness: nil, updated_after: nil }

      expect(product_service).to have_received(:all).with(expected)
    end

    context 'with search params' do
      it 'calls all on the service with all parameters' do
        params = {
          with_family: 'family',
          with_completeness: 'completeness',
          updated_after: 'updated_after'
        }

        service.products(params)

        expect(product_service).to have_received(:all).with(params)
      end
    end
  end

  describe '#published_products' do
    let(:published_product_service) { double(:published_product_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::PublishedProductService).to receive(:new) { published_product_service }
      allow(published_product_service).to receive(:published_products)
    end

    it 'initializes a product service' do
      service.published_products

      expect(Akeneo::PublishedProductService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls all on the service' do
      service.published_products

      expect(published_product_service).to have_received(:published_products).with(updated_after: nil)
    end

    context 'with updated_after' do
      let(:updated_after) { 'friday' }

      it 'calls all on the service' do
        service.published_products(updated_after: updated_after)

        expect(published_product_service).to have_received(:published_products).with(updated_after: 'friday')
      end
    end
  end

  describe '#brothers_and_sisters' do
    let(:product_service) { double(:product_service) }
    let(:product_id) { 42 }
    let(:product_model_service) { double(:product_model_service) }
    let(:family_service) { double(:family_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductService).to receive(:new) { product_service }
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(product_service).to receive(:brothers_and_sisters)
    end

    it 'initializes a product service' do
      service.brothers_and_sisters(product_id)

      expect(Akeneo::ProductService).to have_received(:new).with(
        url: url,
        access_token: access_token,
        product_model_service: product_model_service,
        family_service: family_service
      )
    end

    it 'calls find on the service' do
      service.brothers_and_sisters(product_id)

      expect(product_service).to have_received(:brothers_and_sisters).with(42)
    end
  end

  describe '#product_parent' do
    let(:parent_code) { 'parent_code' }
    let(:product_model_service) { double(:product_model_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(product_model_service).to receive(:find)
    end

    it 'initializes a product model service service' do
      service.product_parent(parent_code)

      expect(Akeneo::ProductModelService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls find on the service' do
      service.product_parent(parent_code)

      expect(product_model_service).to have_received(:find).with('parent_code')
    end
  end

  describe '#parents' do
    let(:product_model_service) { double(:product_model_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(product_model_service).to receive(:all)
    end

    it 'initializes a product model service service' do
      service.parents

      expect(Akeneo::ProductModelService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls all on the service' do
      service.parents

      expect(product_model_service).to have_received(:all).with(with_family: nil)
    end

    context 'with family' do
      let(:family) { 'a_fam' }

      it 'calls all on the service' do
        service.parents(with_family: family)

        expect(product_model_service).to have_received(:all).with(with_family: 'a_fam')
      end
    end
  end

  describe '#create_or_update_product' do
    let(:product_service) { double(Akeneo::ProductService) }
    let(:product_model_service) { double(Akeneo::ProductModelService) }
    let(:family_service) { double(Akeneo::FamilyService) }
    let(:code) { 'code' }
    let(:options) { 'options' }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductService).to receive(:new) { product_service }
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(product_service).to receive(:create_or_update)
    end

    it 'initializes a product service' do
      service.create_or_update_product(code: code, options: options)

      expect(Akeneo::ProductService).to have_received(:new).with(
        url: url,
        access_token: access_token,
        family_service: family_service,
        product_model_service: product_model_service
      )
    end

    it 'initializes a product model service' do
      service.create_or_update_product(code: code, options: options)

      expect(Akeneo::ProductModelService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'initializes a family service' do
      service.create_or_update_product(code: code, options: options)

      expect(Akeneo::FamilyService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls create_or_update_product on the service' do
      service.create_or_update_product(code: code, options: options)

      expect(product_service).to have_received(:create_or_update).with(code, options)
    end
  end

  describe '#create_or_update_product_model' do
    let(:product_model_service) { double(Akeneo::ProductModelService) }
    let(:code) { 'code' }
    let(:options) { 'options' }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(product_model_service).to receive(:create_or_update)
    end

    it 'initializes a product model service' do
      service.create_or_update_product_model(code: code, options: options)

      expect(Akeneo::ProductModelService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls create_or_update_product_model on the service' do
      service.create_or_update_product_model(code: code, options: options)

      expect(product_model_service).to have_received(:create_or_update).with(code, options)
    end
  end

  describe '#image' do
    let(:image_code) { 'image_code' }
    let(:image_service) { double(:image_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ImageService).to receive(:new) { image_service }
      allow(image_service).to receive(:find)
    end

    it 'initializes an image service' do
      service.image(image_code)

      expect(Akeneo::ImageService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls find on the service' do
      service.image(image_code)

      expect(image_service).to have_received(:find).with('image_code')
    end
  end

  describe '#upload_image' do
    let(:code) { 'code' }
    let(:file) { 'file' }
    let(:filename) { 'filename' }
    let(:options) { { some: 'options' } }
    let(:upload_image) do
      service.upload_image(
        code: code,
        file: file,
        filename: filename,
        options: options
      )
    end
    let(:image_service) { double(Akeneo::ImageService) }

    before do
      allow(service).to receive(:image_service) { image_service }
      allow(image_service).to receive(:create_asset)
      allow(image_service).to receive(:create_reference)
    end

    it 'creates an asset' do
      upload_image

      expect(image_service)
        .to have_received(:create_asset)
        .with(code, options)
    end

    it 'creates a reference file' do
      upload_image

      expect(image_service)
        .to have_received(:create_reference)
        .with(code, 'no-locale', file, filename)
    end

    context 'with a locale' do
      let(:options) { { locale: 'en-GB' } }

      it 'passes the locale' do
        upload_image

        expect(image_service)
          .to have_received(:create_reference)
          .with(code, 'en-GB', file, filename)
      end
    end
  end

  describe '#download_image' do
    let(:image_code) { 'image_code' }
    let(:asset_family) { 'asset_family' }
    let(:variation_scopable) { 'ecommerce' }
    let(:image_service) { double(:image_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ImageService).to receive(:new) { image_service }
      allow(image_service).to receive(:download)
    end

    it 'initializes an image service with variation_scopable' do
      service.download_image(image_code, asset_family, variation_scopable)

      expect(Akeneo::ImageService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end
    it 'initializes an image service without variation_scopable' do
      service.download_image(image_code, asset_family)

      expect(Akeneo::ImageService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls download on the service with variation_scopable' do
      service.download_image(image_code, asset_family, variation_scopable)

      expect(image_service).to have_received(:download).with('image_code', 'asset_family', 'ecommerce')
    end

    it 'calls download on the service without variation_scopable' do
      service.download_image(image_code, asset_family)

      expect(image_service).to have_received(:download).with('image_code', 'asset_family', nil)
    end
  end

  describe '#download_file' do
    let(:file_code) { 'file_code' }
    let(:file_service) { double(:file_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::MediaFilesService).to receive(:new) { file_service }
      allow(file_service).to receive(:download)
    end

    it 'initializes an file service' do
      service.download_file(file_code)

      expect(Akeneo::MediaFilesService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls download on the service' do
      service.download_file(file_code)

      expect(file_service).to have_received(:download).with('file_code')
    end
  end

  describe '#product_parent_or_grand_parent' do
    let(:parent_code) { 'parent_code' }
    let(:product_model_service) { double(:product_model_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::ProductModelService).to receive(:new) { product_model_service }
      allow(product_model_service).to receive(:find)
    end

    it 'initializes an product model service' do
      service.product_parent_or_grand_parent(parent_code)

      expect(Akeneo::ProductModelService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls download on the service' do
      service.product_parent_or_grand_parent(parent_code)

      expect(product_model_service).to have_received(:find).with('parent_code')
    end

    context 'with grand parent' do
      let(:parent) { { 'parent' => grand_parent_code } }
      let(:grand_parent) { { 'parent' => nil } }
      let(:grand_parent_code) { 'grand_parent_code' }

      before do
        allow(product_model_service).to receive(:find).and_return(parent, grand_parent)
      end

      it 'finds the grand parent' do
        service.product_parent_or_grand_parent(parent_code)

        expect(product_model_service).to have_received(:find).with('grand_parent_code')
      end

      it 'returns the grand parent' do
        parent_or_grand_parent = service.product_parent_or_grand_parent(parent_code)

        expect(parent_or_grand_parent).to eq(grand_parent)
      end
    end
  end

  describe '#family' do
    let(:family_code) { 'family_code' }
    let(:family_service) { double(:family_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(family_service).to receive(:find)
    end

    it 'initializes a family service' do
      service.family(family_code)

      expect(Akeneo::FamilyService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls find on the service' do
      service.family(family_code)

      expect(family_service).to have_received(:find).with('family_code')
    end
  end

  describe '#family_variant' do
    let(:family_code) { 'family_code' }
    let(:family_variant_code) { 'family_variant_code' }
    let(:family_service) { double(:family_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(family_service).to receive(:variant)
    end

    it 'initializes a family service' do
      service.family_variant(family_code, family_variant_code)

      expect(Akeneo::FamilyService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'calls variant on the service' do
      service.family_variant(family_code, family_variant_code)

      expect(family_service).to have_received(:variant).with('family_code', 'family_variant_code')
    end
  end

  describe '#option_values_of' do
    let(:family_code) { 'family_code' }
    let(:family_variant_code) { 'family_variant_code' }
    let(:family_service) { double(:family_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::FamilyService).to receive(:new) { family_service }
      allow(family_service).to receive(:variant)
    end

    it 'initializes a family service' do
      service.option_values_of(family_code, family_variant_code)

      expect(Akeneo::FamilyService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'loads the family_variant' do
      service.option_values_of(family_code, family_variant_code)

      expect(family_service).to have_received(:variant).with('family_code', 'family_variant_code')
    end

    context 'with no level' do
      it 'extracts the attributes for the levels' do
        response = service.option_values_of(family_code, family_variant_code)

        expect(response).to eq([])
      end
    end

    context 'with one level' do
      let(:variant) do
        {
          'variant_attribute_sets' => [
            { 'level' => 1, 'axes' => %w[x] }
          ]
        }
      end

      before do
        allow(family_service).to receive(:variant) { variant }
      end

      it 'extracts the attributes for the levels' do
        response = service.option_values_of(family_code, family_variant_code)

        expect(response).to eq(%w[x])
      end
    end

    context 'with two levels' do
      let(:variant) do
        {
          'variant_attribute_sets' => [
            { 'level' => 1, 'axes' => %w[x] },
            { 'level' => 2, 'axes' => %w[y] }
          ]
        }
      end

      before do
        allow(family_service).to receive(:variant) { variant }
      end

      it 'extracts the attributes for the levels' do
        response = service.option_values_of(family_code, family_variant_code)

        expect(response).to eq(%w[x y])
      end
    end
  end

  describe '#category' do
    let(:category_code) { 'category_code' }
    let(:category_service) { double(:category_service) }

    before do
      service.access_token = access_token
      allow(Akeneo::CategoryService).to receive(:new) { category_service }
      allow(category_service).to receive(:find)
    end

    it 'initializes a category service' do
      service.category(category_code)

      expect(Akeneo::CategoryService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'call find on the service' do
      service.category(category_code)

      expect(category_service).to have_received(:find).with('category_code')
    end
  end

  describe '#categories' do
    let(:category_code) { 'category_code' }
    let(:category_service) { double(:category_service) }
    let(:category) do
      nil
    end

    before do
      service.access_token = access_token
      allow(Akeneo::CategoryService).to receive(:new) { category_service }
      allow(category_service).to receive(:find) { category }
    end

    it 'initializes a category service' do
      service.categories(category_code)

      expect(Akeneo::CategoryService).to have_received(:new).with(
        url: url,
        access_token: access_token
      )
    end

    it 'call find on the service' do
      service.categories(category_code)

      expect(category_service).to have_received(:find).with('category_code')
    end

    context 'when the category does not exist' do
      it 'returns an empty array' do
        result = service.categories(category_code)

        expect(result).to eq([])
      end
    end

    context 'when the category exists and has no parent' do
      let(:category) do
        {}
      end

      it 'returns the category in the array' do
        result = service.categories(category_code)

        expect(result).to contain_exactly(category)
      end
    end

    context 'when the category exists and has a parent' do
      let(:category) do
        {
          'parent' => 'a_parent_category_code'
        }
      end
      let(:parent_category) do
        {}
      end

      before do
        allow(category_service).to receive(:find).and_return(category, parent_category)
      end

      it 'call find on the service' do
        service.categories(category_code)

        expect(category_service).to have_received(:find).with('category_code')
      end

      it 'tries to find the parent' do
        service.categories(category_code)

        expect(category_service).to have_received(:find).with('a_parent_category_code')
      end

      it 'returns the both categories in the array' do
        result = service.categories(category_code)

        expect(result).to contain_exactly(category, parent_category)
      end
    end

    context 'when the parent is the master category' do
      let(:category) do
        {
          'parent' => 'master'
        }
      end

      it 'does not call find for the master category' do
        service.categories(category_code)

        expect(category_service).not_to have_received(:find).with('master')
      end

      it 'returns the category in the array' do
        result = service.categories(category_code)

        expect(result).to contain_exactly(category)
      end
    end
  end
end
