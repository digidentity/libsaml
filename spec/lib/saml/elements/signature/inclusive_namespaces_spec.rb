require 'spec_helper'

describe ::Saml::Elements::Signature::InclusiveNamespaces do
  subject { described_class.new(:prefix_list => inclusive_namespaces) }
  before { Saml::Config.inclusive_namespaces_prefix_list = 'XXX' }

  context 'no prefix_list passed as argument' do
    let(:inclusive_namespaces) { nil }

    it 'uses the globally configured prefix_list' do
      expect(subject.prefix_list).to eq 'XXX'
    end
  end

  context 'a prefix_list is passed as an argument' do
    let(:inclusive_namespaces) { 'ARG' }

    it 'uses the given prefix_list' do
      expect(subject.prefix_list).to eq 'ARG'
    end
  end
end
