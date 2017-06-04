require 'spec_helper'

describe ::Saml::Elements::Signature::InclusiveNamespaces do
  before { Saml::Config.inclusive_namespaces_prefix_list = 'XXX' }

  context 'no prefix_list passed as argument' do
    it 'uses the globally configured prefix_list' do
      expect(subject.prefix_list).to eq Saml::Config.inclusive_namespaces_prefix_list
    end
  end

  context 'a prefix_list is passed as an argument' do
    subject { described_class.new(:prefix_list => 'ARG') }

    it 'uses the given prefix_list' do
      expect(subject.prefix_list).to eq 'ARG'
    end
  end
end
