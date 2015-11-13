require 'spec_helper'

describe Saml::Elements::AttributeStatement do
  let(:attribute_statement_xml) { File.read(File.join('spec', 'fixtures', 'attribute_statement.xml')) }
  let(:attribute_statement) { Saml::Elements::AttributeStatement.parse(attribute_statement_xml, :single => true) }

  describe '#parse' do
    it 'should create a AttributeStatement' do
      attribute_statement.should be_a(Saml::Elements::AttributeStatement)
    end

    it 'should parse attribute' do
      attribute_statement.attribute.first.should be_a(Saml::Elements::Attribute)
    end

    it 'should parse encrypted attributes' do
      attribute_statement.encrypted_attributes.first.should be_a Saml::Elements::EncryptedAttribute
    end
  end

  describe '#fetch_attribute' do
    it 'returns the attribute value content' do
      attribute_statement.fetch_attribute('urn:ServiceID').should == '1'
    end
  end

  describe '#fetch_attribute_value' do
    it 'returns the attribute value' do
      attribute_statement.fetch_attribute_value('urn:ServiceID').content.should == '1'
    end
  end
end
