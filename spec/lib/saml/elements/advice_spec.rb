require 'spec_helper'

describe Saml::Elements::Advice do

  it 'includes the AdviceType complex type' do
    expect(described_class.ancestors).to include Saml::ComplexTypes::AdviceType
  end

  it 'has a tag' do
    expect(described_class.tag_name).to eq 'Advice'
  end

  it 'has a namespace' do
    expect(described_class.namespace).to eq 'saml'
  end

  describe '#parse' do
    let(:advice_type_xml) { File.read(File.join('spec','fixtures','advice_type.xml')) }
    let(:advice)     { described_class.parse(advice_type_xml, single: true) }

    it 'parses all the Assertions' do
      expect(advice.assertions.count).to eq 2
    end

    it 'has the correct Assertion type' do
      expect(advice.assertions.first).to be_a(Saml::Assertion)
    end
  end

end
