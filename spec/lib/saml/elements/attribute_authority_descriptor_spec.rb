require 'spec_helper'

describe Saml::Elements::AttributeAuthorityDescriptor do

  describe 'required fields' do
    [:attribute_service].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it 'should check the presence of #{field}' do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end
  end

  describe 'optional fields' do
    [:name_id_format].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.errors.entries.should eq []
        subject.send("#{field}=", '')
        subject.errors.entries.should eq []
      end
    end
  end

  describe '#parse' do
    let(:authority_provider_xml) { File.read('spec/fixtures/metadata/authority_provider.xml') }
    let(:entity_descriptor) { Saml::Elements::EntityDescriptor.parse(authority_provider_xml) }

    let(:attribute_authority_descriptor) { entity_descriptor.attribute_authority_descriptor }

    it 'should parse' do
      attribute_authority_descriptor.should be_a(Saml::Elements::AttributeAuthorityDescriptor)
    end

    it 'should be valid' do
      attribute_authority_descriptor.should be_valid
    end

    describe '#attribute_service' do
      let(:attribute_service) { attribute_authority_descriptor.attribute_service.first }

      it 'knows its location' do
        attribute_service.location.should eq 'https://idp.example.com/SAML/AA/URI'
      end

      it 'knows its binding' do
        attribute_service.binding.should eq Saml::ProtocolBinding::SOAP
      end
    end

    describe '#NameIDFormat' do
      let(:name_id_format) { attribute_authority_descriptor.name_id_format.first }

      it 'knows its value' do
        name_id_format.value.should eq 'urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName'
      end
    end
  end
end
