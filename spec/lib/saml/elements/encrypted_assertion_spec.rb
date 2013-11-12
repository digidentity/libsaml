require "spec_helper"

describe Saml::Elements::EncryptedAssertion do

  let(:xml) { File.read File.join("spec", "fixtures", "encrypted_assertion.xml") }
  subject   { described_class.parse(xml, single: true) }

  describe "#parse" do
    it "should create the EncryptedAttribute" do
      expect(subject).to be_a Saml::Elements::EncryptedAssertion
    end

    it "should parse the encrypted data" do
      expect(subject.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
    end

    it "should parse the encrypted key" do
      expect(subject.encrypted_keys.first).to be_a Xmlenc::Builder::EncryptedKey
    end
  end
end
