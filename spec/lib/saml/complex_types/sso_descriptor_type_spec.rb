require 'spec_helper'

describe Saml::ComplexTypes::SSODescriptorType do
  let(:sso_descriptor) { FactoryBot.build(:sso_descriptor_type_dummy) }

  describe 'Optional fields' do
    [:artifact_resolution_services, :single_logout_services, :name_id_formats].each do |field|
      it "should have the #{field} field" do
        expect(sso_descriptor).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        sso_descriptor.send("#{field}=", nil)
        expect(sso_descriptor).to be_valid
      end
    end
  end
end
