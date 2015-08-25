require 'spec_helper'

describe Saml::Elements::NameIdFormat do

  it 'has a tag' do
    described_class.tag_name.should eq 'NameIDFormat'
  end

  it 'has a namespace' do
    described_class.namespace.should eq 'md'
  end

end
