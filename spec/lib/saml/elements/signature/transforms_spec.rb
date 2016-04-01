require 'spec_helper'

describe ::Saml::Elements::Signature::Transforms do
  let(:inclusive_namespaces) { 'ARG' }
  before { Saml::Config.inclusive_namespaces_prefix_list = 'XXX' }

  context 'no inclusive_namespaces passed as argument' do
    it 'uses the globally configured prefix_list' do
      expect(subject.transform.last.inclusive_namespaces.prefix_list).to eq Saml::Config.inclusive_namespaces_prefix_list
    end
  end

  context 'inclusive_namespaces is passed as an argument' do
    subject { described_class.new(:inclusive_namespaces => 'ARG') }

    it 'uses the given inclusive_namespaces as prefix_list' do
      expect(subject.transform.last.inclusive_namespaces.prefix_list).to eq 'ARG'
    end
  end
end
