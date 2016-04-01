require 'spec_helper'

describe ::Saml::Elements::Signature::SignedInfo do
  let(:inclusive_namespaces) { 'ARG' }
  subject { described_class.new :inclusive_namespaces => inclusive_namespaces }

  it 'passes the given inclusive_namespaces to the Reference element' do
    expect(::Saml::Elements::Signature::SignedInfo).to receive(:new).with(including(:inclusive_namespaces => inclusive_namespaces))
    subject
  end
end
