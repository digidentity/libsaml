require 'spec_helper'

describe Saml::ComplexTypes::SSODescriptorType do
  let(:sso_descriptor) { FactoryGirl.build(:sso_descriptor_type_dummy) }

  describe "Required fields" do
    [:protocol_support_enumeration].each do |field|
      it "should have the #{field} field" do
        sso_descriptor.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        sso_descriptor.send("#{field}=", nil)
        sso_descriptor.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:valid_until, :cache_duration, :error_url,
     :key_descriptors, :artifact_resolution_services, :single_logout_services].each do |field|
      it "should have the #{field} field" do
        sso_descriptor.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        sso_descriptor.send("#{field}=", nil)
        sso_descriptor.should be_valid
      end
    end
  end

  describe "#find_key_descriptor" do
    let(:key_descriptor_1) { FactoryGirl.build :key_descriptor, use: "encryption" }

    let(:key_descriptor_2) do
      key_descriptor = FactoryGirl.build :key_descriptor, use: "signing"
      key_descriptor.key_info.key_name = "key"
      key_descriptor
    end

    before do
      sso_descriptor.key_descriptors = [ key_descriptor_1, key_descriptor_2 ]
    end

    context "when a key name is specified" do
      it "finds the key descriptor by the specified key name and use" do
        sso_descriptor.find_key_descriptor("key", "signing").should be_a Saml::Elements::KeyDescriptor
      end
    end

    context "when a key name isn't specified" do
      it "finds the key descriptor by use" do
        sso_descriptor.find_key_descriptor(nil, "encryption").should be_a Saml::Elements::KeyDescriptor
      end
    end
  end
end
