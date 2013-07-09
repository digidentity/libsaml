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
end
