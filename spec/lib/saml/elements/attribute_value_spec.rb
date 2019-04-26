require 'spec_helper'

describe Saml::Elements::AttributeValue do

  subject { FactoryBot.build(:attribute_value) }

  describe 'optional fields' do
    [:encrypted_id, :type, :content].each do |field|
      it "should respond to the '#{field}' field" do
        expect(subject).to respond_to(field)
      end
    end
  end

  describe '#parse' do
    let(:attribute_xml) { File.read(File.join('spec','fixtures','attribute.xml')) }
    let(:attribute_value) { Saml::Elements::AttributeValue.parse(attribute_xml, single: true) }

    it 'should create a Attribute' do
      expect(attribute_value).to be_a Saml::Elements::AttributeValue
    end

    it 'should know its type' do
      expect(attribute_value.type).to eq 'xs:string'
    end

    context 'with an EncryptedID element' do
      let(:attribute_xml) { File.read(File.join('spec','fixtures','attribute_value.xml')) }

      it 'should create an AttributeValue' do
        expect(attribute_value).to be_a Saml::Elements::AttributeValue
      end

      it 'has an EncryptedID element' do
        expect(attribute_value.encrypted_id).to be_a Saml::Elements::EncryptedID
      end
    end
  end
end
