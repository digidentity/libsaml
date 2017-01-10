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

    it "should store the xml_node value" do
      expect(subject.xml_node).to be_a Nokogiri::XML::Node
    end
  end

  describe '#encrypt' do
    let(:name_id)           { Saml::Elements::NameId.new(value: 'NAAM') }
    let(:entity_descriptor) { Saml::Elements::EntityDescriptor.parse(File.read('spec/fixtures/metadata/service_provider.xml')) }
    let(:encrypted_id)      { Saml::Elements::EncryptedID.new(name_id: name_id) }
    let(:key_descriptors)   { entity_descriptor.sp_sso_descriptor.find_key_descriptors_by_use('encryption') }

    context 'when a single key descriptor is given' do
      before { encrypted_id.encrypt(key_descriptors.first) }

      it 'encrypts the encrypted ID for the given key descriptor' do
        aggregate_failures do
          expect(encrypted_id.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
          expect(encrypted_id.encrypted_keys.count).to eq 1
          expect(encrypted_id.encrypted_keys.first).to be_a Xmlenc::Builder::EncryptedKey
          expect(encrypted_id.encrypted_keys.first.key_info.key_name).to eq '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
          expect(encrypted_id.name_id).to be_nil
        end
      end
    end

    context 'when multiple key descriptors are given' do
      before { encrypted_id.encrypt(key_descriptors) }

      it 'encrypts the encrypted ID for each given key descriptor' do
        aggregate_failures do
          expect(encrypted_id.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
          expect(encrypted_id.encrypted_keys.count).to eq 2
          expect(encrypted_id.encrypted_keys.first).to be_a Xmlenc::Builder::EncryptedKey
          expect(encrypted_id.encrypted_keys.first.key_info.key_name).to eq '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
          expect(encrypted_id.encrypted_keys.second).to be_a Xmlenc::Builder::EncryptedKey
          expect(encrypted_id.encrypted_keys.second.key_info.key_name).to eq '82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
          expect(encrypted_id.name_id).to be_nil
        end
      end
    end
  end

end
