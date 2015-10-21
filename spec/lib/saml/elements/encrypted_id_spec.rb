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
end
