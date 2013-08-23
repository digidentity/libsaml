require 'spec_helper'

describe Saml::Elements::EntityDescriptor do
  let(:entity_descriptor) { FactoryGirl.build(:entity_descriptor) }

  describe "Required fields" do
    [:entity_id].each do |field|
      it "should have the #{field} field" do
        entity_descriptor.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        entity_descriptor.send("#{field}=", nil)
        entity_descriptor.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:valid_until, :cache_duration, :name, :extensions, :organization, :contact_persons, :sp_sso_descriptor, :idp_sso_descriptor].each do |field|
      it "should have the #{field} field" do
        entity_descriptor.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        entity_descriptor.send("#{field}=", nil)
        entity_descriptor.should be_valid
      end
    end
  end
end
