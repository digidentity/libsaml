require 'spec_helper'

describe Saml::Elements::KeyDescriptor do
  let(:key_descriptor) { FactoryGirl.build(:key_descriptor) }

  describe "certificate" do
    let(:xml)     { File.read('spec/fixtures/metadata_with_whitespace.xml') }

    it "does not raise an error if the certificate is invalid" do
      expect {
        described_class.new(:certificate => "invalid")
      }.not_to raise_error
    end

    it "removes any whitespace character in the string" do
      expect(described_class.parse(xml, single: true).certificate.to_s).to eql(key_descriptor.certificate.to_s)
    end
  end

  describe "Required fields" do
    [:certificate].each do |field|
      it "should have the #{field} field" do
        key_descriptor.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        key_descriptor.send("#{field}=", nil)
        key_descriptor.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:use].each do |field|
      it "should have the #{field} field" do
        key_descriptor.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        key_descriptor.send("#{field}=", nil)
        key_descriptor.should be_valid
      end
    end
  end
end
