require 'spec_helper'

describe Saml::Elements::Signature::DigestMethod do
  it 'has a tag' do
    expect(described_class.tag_name).to eq 'DigestMethod'
  end

  it 'has a namespace' do
    expect(described_class.namespace).to eq 'ds'
  end

  it 'set the algorithm from the saml config' do
    old = Saml::Config.digest_algorithm

    Saml::Config.digest_algorithm = "my algorithm"
    expect(subject.algorithm).to eq "my algorithm"

    Saml::Config.digest_algorithm = old
  end

end
