require 'spec_helper'

describe Saml::Elements::EntityDescriptor do
  let(:entity_descriptor) { FactoryBot.build(:entity_descriptor) }

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
    [:valid_until, :cache_duration, :name, :extensions, :organization, :contact_persons,
     :sp_sso_descriptor, :idp_sso_descriptor, :attribute_authority_descriptor].each do |field|
      it "should have the #{field} field" do
        entity_descriptor.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        entity_descriptor.send("#{field}=", nil)
        entity_descriptor.should be_valid
      end
    end

    describe "#cache_duration" do
      let(:xml)     { File.read('spec/fixtures/provider_with_cache_duration.xml') }

      it "casts the cache_duration to a String" do
        described_class.parse(xml, single: true).cache_duration.should be_a String
      end
    end
  end
end
