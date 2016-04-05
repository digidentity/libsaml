require 'spec_helper'

describe ::Saml::Elements::Signature::Reference do
  let(:inclusive_namespaces) { 'ARG' }
  subject { described_class.new :inclusive_namespaces_prefix_list => inclusive_namespaces }

  it 'passes the given inclusive_namespaces to Transforms' do
    expect(::Saml::Elements::Signature::Transforms).to receive(:new).with(:inclusive_namespaces_prefix_list => inclusive_namespaces)
    subject
  end
end
