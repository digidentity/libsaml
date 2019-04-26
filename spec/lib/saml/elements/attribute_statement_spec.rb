require 'spec_helper'

describe Saml::Elements::AttributeStatement do
  let(:attribute_statement_xml) { File.read(File.join('spec', 'fixtures', 'attribute_statement.xml')) }
  let(:attribute_statement) { Saml::Elements::AttributeStatement.parse(attribute_statement_xml, single: true) }

  let(:attribute_1) { FactoryBot.build(:attribute, name: 'key_1') }
  let(:attribute_2) { FactoryBot.build(:attribute, name: 'key_2') }

  it 'includes the AttributeFetcher' do
    expect(described_class.ancestors).to include Saml::AttributeFetcher
  end

  describe "Optional fields" do
    [:attributes, :encrypted_attributes].each do |field|
      it "should have the #{field} field" do
        expect(attribute_statement).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        attribute_statement.send("#{field}=", nil)
        expect(attribute_statement).to be_valid
        attribute_statement.send("#{field}=", "")
        expect(attribute_statement).to be_valid
      end
    end
  end

  describe '#parse' do
    it 'should create a AttributeStatement' do
      expect(attribute_statement).to be_a(Saml::Elements::AttributeStatement)
    end

    it 'should parse attribute' do
      expect(attribute_statement.attributes.first).to be_a(Saml::Elements::Attribute)
    end

    it 'should parse encrypted attributes' do
      expect(attribute_statement.encrypted_attributes.first).to be_a Saml::Elements::EncryptedAttribute
    end
  end

  describe '#fetch_attribute' do
    it 'returns the attribute value content' do
      expect(attribute_statement.fetch_attribute('urn:ServiceID')).to eq('1')
    end
  end

  describe '#fetch_attribute_value' do
    it 'returns the attribute value' do
      expect(attribute_statement.fetch_attribute_value('urn:ServiceID').content).to eq('1')
    end
  end
end
