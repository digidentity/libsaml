require 'spec_helper'

describe Saml::Elements::NameIdFormat do

  it 'has a tag' do
    expect(described_class.tag_name).to eq 'NameIDFormat'
  end

  it 'has a namespace' do
    expect(described_class.namespace).to eq 'md'
  end

end
