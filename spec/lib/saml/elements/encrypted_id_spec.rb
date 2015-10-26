require "spec_helper"

describe Saml::Elements::EncryptedID do

  let(:xml) { File.read File.join("spec", "fixtures", "encrypted_id.xml") }
  subject   { described_class.parse(xml, single: true) }

  describe "Required fields" do
    [:encrypted_data].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        subject.send("#{field}=", nil)
        subject.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:encrypted_keys].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.should be_valid
        subject.send("#{field}=", "")
        subject.should be_valid
      end
    end
  end

  describe "#parse" do
    it "should create the EncryptedAttribute" do
      expect(subject).to be_a Saml::Elements::EncryptedID
    end

    it "should parse the encrypted data" do
      expect(subject.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
    end

    it "should parse the encrypted key" do
      expect(subject.encrypted_keys.first).to be_a Xmlenc::Builder::EncryptedKey
    end
  end

  describe '#encrypt' do
    let(:name_id) { Saml::Elements::NameId.new(value: 'NAAM') }
    let(:key_name) { '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8' }
    let(:entity_descriptor) { Saml::Elements::EntityDescriptor.parse(File.read('spec/fixtures/metadata/service_provider.xml')) }
    let(:key_descriptor) { entity_descriptor.sp_sso_descriptor.find_key_descriptor(key_name, 'encryption') }
    let(:encrypted_id) { Saml::Elements::EncryptedID.new(name_id: name_id) }

    before { encrypted_id.encrypt(key_descriptor) }

    it 'builds #encrypted_data' do
      expect(encrypted_id.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
    end

    it 'builds #encrypted_keys' do
      expect(encrypted_id.encrypted_keys).to be_a Array
    end

    it '#encrypted_keys are of type EncryptedKey' do
      expect(encrypted_id.encrypted_keys.first).to be_a Xmlenc::Builder::EncryptedKey
    end

    it '#name_id is nil' do
      expect(encrypted_id.name_id).to eq nil
    end
  end
end
