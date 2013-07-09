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
end
