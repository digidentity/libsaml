require "spec_helper"

describe Saml::Elements::EncryptedAttribute do

  let(:xml) { File.read File.join("spec", "fixtures", "encrypted_attribute.xml") }
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
end
