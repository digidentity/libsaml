require 'spec_helper'

describe Saml::ProviderStores::File do
  let(:file_store) { described_class.new("spec/fixtures/metadata", "spec/fixtures/key.pem") }
  describe "initialize" do

    it "creates a store of providers" do
      file_store.providers.first.should be_a(Saml::ProviderStores::File::Provider)
    end
  end

  describe "#find_by_entity_id" do
    it "returns the identity_provider with entity_id" do
      file_store.find_by_entity_id("https://idp.example.com").type.should == "identity_provider"
    end
    it "returns the service_provider with entity_id" do
      file_store.find_by_entity_id("https://sp.example.com").type.should == "service_provider"
    end
  end
end