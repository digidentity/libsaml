require 'spec_helper'

describe Saml do
  after :each do
    Saml.current_provider = nil
    Saml.current_store    = nil
  end

  describe 'InvalidStoreError' do
    context 'with unrecognized store' do
      it 'returns a descriptive message' do
        expect(Saml::Errors::InvalidStore.new('store').message).to be == 'Store store not registered'
      end
    end

    context 'without registered store' do
      it 'returns a descriptive message' do
        expect(Saml::Errors::InvalidStore.new.message).to be == 'Store cannot be blank'
      end
    end
  end

  describe '.current_provider=' do
    it 'sets the current provider' do
      Saml.current_provider= 'provider'
      expect(Thread.current['saml_current_provider']).to be == 'provider'
    end
  end

  describe '.current_provider' do
    it 'returns the current provider' do
      Thread.current['saml_current_provider'] = 'current_provider'
      expect(Saml.current_provider).to be == 'current_provider'
    end
  end

  describe '.current_store=' do
    it 'sets the current provider store' do
      Saml.current_store = :file
      expect(Thread.current['saml_current_store']).to be == :file
    end
  end

  describe '.current_store' do
    it 'returns the current provider' do
      Thread.current['saml_current_store'] = :file
      expect(Saml.current_store).to be_a(Saml::ProviderStores::File)
    end

    it 'returns the default registered store' do
      Thread.current['saml_current_store'] = nil
      Saml::Config.stub(:registered_stores).and_return({default: 'default_store'})
      Saml::Config.stub(:default_store).and_return :default
      expect(Saml.current_store).to be == 'default_store'
    end

    it 'raises an error if the store is not set and nothing is registered' do
      Thread.current['saml_current_store'] = nil
      Saml::Config.stub(:registered_stores).and_return({})
      expect { Saml.current_store }.to raise_error(Saml::Errors::InvalidStore)
    end
  end

  describe '.provider' do
    it 'returns the current provider if it matches the entity id' do
      current_provider     = double('provider', entity_id: 'entity_id')
      Saml.current_provider=(current_provider)
      expect(Saml.provider('entity_id')).to be == current_provider
    end

    it 'returns the provider' do
      Saml.current_store.should_receive(:find_by_entity_id).and_return('provider')
      Saml.provider('entity_id').should == 'provider'
    end

    it 'raises an error if the provider is not found' do
      Saml.current_store.should_receive(:find_by_entity_id).and_return(nil)
      expect {
        Saml.provider('entity_id')
      }.to raise_error(Saml::Errors::InvalidProvider)
    end
  end

  describe ".parse_message" do
    let(:message) { "message" }

    context "with default types" do
      [:authn_request, :response, :logout_request, :logout_response, :artifact_resolve, :artifact_response].each do |type|
        it "parses messages with type '#{type}'" do
          "Saml::#{type.to_s.camelize}".constantize.should_receive(:parse).with(message, single: true)
          Saml.parse_message(message, type)
        end
      end
    end

    context "with custom types" do
      let(:type) { "foo/bar" }

      module Foo
        class Bar
          def self.parse
          end
        end
      end

      it "parses messages of a custom class, based on type" do
        type.to_s.camelize.safe_constantize.should_receive(:parse).with(message, single: true)
        Saml.parse_message(message, type)
      end
    end

    context "with unknown types" do
      let(:type) { :bar }

      it "returns nil when the class is unknown" do
        Saml.parse_message(message, type).should be_nil
      end
    end
  end
end
