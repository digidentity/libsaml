require 'spec_helper'

describe Saml::ProviderStores::Url do
  describe '#find_by_entity_id' do
    it 'returns the identity_provider with entity_id' do
      Saml::Util.should_receive(:download_metadata_xml).
          with('https://example.com/metadata').
          and_return(File.read('spec/fixtures/metadata/identity_provider.xml'))
      described_class.find_by_metadata_location('https://example.com/metadata').type.should == 'identity_provider'
    end

    it 'returns the service_provider with entity_id' do
      Saml::Util.should_receive(:download_metadata_xml).
          with('https://example.com/metadata').
          and_return(File.read('spec/fixtures/metadata/service_provider.xml'))
      described_class.find_by_metadata_location('https://example.com/metadata').type.should == 'service_provider'
    end
  end
end
