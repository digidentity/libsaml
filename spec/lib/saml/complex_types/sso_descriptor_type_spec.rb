require 'spec_helper'

describe Saml::ComplexTypes::SSODescriptorType do
  let(:sso_descriptor) { FactoryGirl.build(:sso_descriptor_type_dummy) }

  describe 'Optional fields' do
    [:artifact_resolution_services, :single_logout_services].each do |field|
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
