require "spec_helper"

describe Saml::Elements::EncryptedAttribute do

  let(:xml) { File.read File.join("spec", "fixtures", "encrypted_attribute.xml") }
  subject   { described_class.parse(xml, single: true) }

  describe "Required fields" do
    [:encrypted_data].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "Optional fields" do
    [:encrypted_keys].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        expect(subject).to be_valid
      end
    end
  end

  describe "#parse" do
    it "should create the EncryptedAttribute" do
      expect(subject).to be_a Saml::Elements::EncryptedAttribute
    end

    it "should parse the encrypted data" do
      expect(subject.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
    end

    it "should have no encrypted key in the root" do
      expect(subject.encrypted_keys).to match_array []
    end
  end

  describe '#encrypt' do
    let(:attribute) { Saml::Elements::Attribute.new }

    let(:entity_descriptor) { Saml::Elements::EntityDescriptor.parse File.read('spec/fixtures/metadata/service_provider.xml') }
    let(:key_descriptor) { entity_descriptor.sp_sso_descriptor.find_key_descriptor('22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8', 'encryption') }

    let(:encrypted_key_data) do
      [
        [ key_descriptor, { recipient: 'recipient' } ]
      ]
    end

    let(:encrypted_data_options) do
      { id: 'encrypted-data-id' }
    end

    let(:encrypt) { subject.encrypt(attribute, encrypted_key_data, encrypted_data_options) }

    it 'calls #encrypt_element' do
      expect(Saml::Util).to receive(:encrypt_element).with(subject, attribute, encrypted_key_data, encrypted_data_options)
      encrypt
    end

    it 'builds an encrypted data element' do
      encrypt
      expect(subject.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
    end

    it 'sets the ID of the encrypted ID' do
      encrypt
      expect(subject.encrypted_data.id).to eq 'encrypted-data-id'
    end

    context 'when there is only one key descriptor' do
      let(:encrypted_key) { subject.encrypted_keys.first }

      it 'builds an encrypted key element' do
        encrypt

        aggregate_failures do
          expect(subject.encrypted_keys).to be_an Array
          expect(subject.encrypted_keys.size).to eq 1
          expect(encrypted_key).to be_a Xmlenc::Builder::EncryptedKey
        end
      end

      # NOTE The xmlmapper gem will order XML namespaces differently under JRuby and MRI

      let(:xml_attribute_jruby) { "<saml:Attribute xmlns:ext=\"urn:oasis:names:tc:SAML:attributes:ext\" xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\"/>" }
      let(:xml_attribute_mri) { '<saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:ext="urn:oasis:names:tc:SAML:attributes:ext"/>' }
      it 'encrypts the XML of the passed in attribute' do
        if RUBY_ENGINE == 'jruby'
          expect_any_instance_of(Xmlenc::Builder::EncryptedData).to receive(:encrypt).with(xml_attribute_jruby, {}).and_call_original
          encrypt
        else
          expect_any_instance_of(Xmlenc::Builder::EncryptedData).to receive(:encrypt).with(xml_attribute_mri, {}).and_call_original
          encrypt
        end
      end

      it 'matches the carried key name to the encrypted data key name' do
        encrypt
        expect(encrypted_key.carried_key_name).to eq subject.encrypted_data.key_info.key_name
      end

      it 'sets the recipient' do
        encrypt
        expect(encrypted_key.recipient).to eq 'recipient'
      end
    end

    context 'when there are multiple key descriptors' do
      let(:encrypted_key_data) do
        [
          [ key_descriptor, { recipient: 'recipient' } ],
          [ key_descriptor, { recipient: 'another-recipient' } ]
        ]
      end

      it 'builts an encrypted key element for each key descriptor' do
        encrypt

        aggregate_failures do
          expect(subject.encrypted_keys).to be_an Array
          expect(subject.encrypted_keys.size).to eq 2
          expect(subject.encrypted_keys.first).to be_a Xmlenc::Builder::EncryptedKey
          expect(subject.encrypted_keys.second).to be_a Xmlenc::Builder::EncryptedKey
        end
      end

      it 'matches all of the carried key names to the encrypted data key name' do
        encrypt

        aggregate_failures do
          expect(subject.encrypted_keys.first.carried_key_name).to eq subject.encrypted_data.key_info.key_name
          expect(subject.encrypted_keys.second.carried_key_name).to eq subject.encrypted_data.key_info.key_name
        end
      end

      it 'sets all of the recipients' do
        encrypt

        aggregate_failures do
          expect(subject.encrypted_keys.first.recipient).to eq 'recipient'
          expect(subject.encrypted_keys.second.recipient).to eq 'another-recipient'
        end
      end
    end
  end
end
