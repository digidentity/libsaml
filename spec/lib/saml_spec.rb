require 'spec_helper'

describe Saml do
  describe '.provider' do
    it 'returns the provider' do
      Saml::Config.provider_store.should_receive(:find_by_entity_id).and_return('provider')
      Saml.provider('entity_id').should == 'provider'
    end

    it 'raises an error if the provider is not found' do
      Saml::Config.provider_store.should_receive(:find_by_entity_id).and_return(nil)
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
