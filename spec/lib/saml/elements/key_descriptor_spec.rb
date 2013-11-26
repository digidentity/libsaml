require 'spec_helper'

describe Saml::Elements::KeyDescriptor do
  let(:key_descriptor) { FactoryGirl.build(:key_descriptor) }

  describe "certificate" do
    it "does not raise an error if the certificate is invalid" do
      expect {
        described_class.new(:certificate => "invalid")
      }.not_to raise_error
    end

    describe "Base64 encoding format" do
      let(:pem_certificate)         { File.read('spec/fixtures/certificate.pem') }
      let(:der_certificate)         { File.read('spec/fixtures/certificate.der') }
      let(:key_descriptor_with_pem) { FactoryGirl.build(:key_descriptor, certificate: pem_certificate) }
      let(:key_descriptor_with_der) { FactoryGirl.build(:key_descriptor, certificate: der_certificate) }

      it "supports a encoded certificate (such as: .pem)" do
        expect(key_descriptor_with_pem.certificate.to_text).to eql key_descriptor.certificate.to_text
      end

      it "supports a binary (decoded) certificate (such as: .der)" do
        expect(key_descriptor_with_der.certificate.to_text).to eql key_descriptor.certificate.to_text
      end
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
