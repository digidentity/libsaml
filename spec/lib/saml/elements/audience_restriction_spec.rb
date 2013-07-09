require 'spec_helper'

describe Saml::Elements::AudienceRestriction do

  let(:audience_restriction) { build(:audience_restriction) }

  describe "Optional fields" do
    [:audience].each do |field|
      it "should have the #{field} field" do
        audience_restriction.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        audience_restriction.send("#{field}=", nil)
        audience_restriction.should be_valid
        audience_restriction.send("#{field}=", "")
        audience_restriction.should be_valid
      end
    end
  end

  describe "#parse" do
    let(:audience_restriction_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:audience_restriction) { Saml::Elements::AudienceRestriction.parse(audience_restriction_xml, :single => true) }

    it "should create a Subject" do
      audience_restriction.should be_a(Saml::Elements::AudienceRestriction)
    end

    it "should parse audience" do
      audience_restriction.audience.should == "ServiceProvider"
    end
  end
end
