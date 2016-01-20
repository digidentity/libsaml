require 'spec_helper'

describe Saml::ProviderStores::File do
  let(:file_store) { described_class.new('spec/fixtures/metadata', 'spec/fixtures/key.pem') }
  let(:idp_entity_id) { 'https://idp.example.com' }
  let(:sp_entity_id) { 'https://sp.example.com' }

  describe 'initialize' do
    it 'creates a store of providers' do
      file_store.providers.values.first.should be_a(Saml::BasicProvider)
    end
  end

  describe '#find_by_entity_id' do
    it 'returns the identity_provider with entity_id' do
      file_store.find_by_entity_id(idp_entity_id).type.should eq('identity_provider')
    end
    it 'returns the service_provider with entity_id' do
      file_store.find_by_entity_id(sp_entity_id).type.should eq('service_provider')
    end
  end

  describe '#find_by_source_id' do
    let(:idp_source_id) { Digest::SHA1.digest(idp_entity_id) }
    let(:sp_source_id) { Digest::SHA1.digest(sp_entity_id) }

    it 'returns the identity_provider with entity_id' do
      file_store.find_by_source_id(idp_source_id).type.should eq('identity_provider')
    end
    it 'returns the service_provider with entity_id' do
      file_store.find_by_source_id(sp_source_id).type.should eq('service_provider')
    end
    it 'returns nil when not found' do
      file_store.find_by_source_id('non-existing-sha1').should be_nil
    end
  end

  describe 'key file with password' do
    let(:file_store) { described_class.new('spec/fixtures/metadata', 'spec/fixtures/key_with_pwd.pem', 'my_password') }
    describe 'initialize' do
      it 'creates a store of providers' do
        file_store.providers.values.first.should be_a(Saml::BasicProvider)
      end
    end
  end

  describe 'with a separate signing key' do
    let(:file_store) { described_class.new('spec/fixtures/metadata', 'spec/fixtures/key.pem', nil, 'spec/fixtures/signing_key.pem') }
    describe 'initialize' do
      it 'creates a store of providers' do
        file_store.providers.values.first.should be_a(Saml::BasicProvider)
      end
    end
  end

end
