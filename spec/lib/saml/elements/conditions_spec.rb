require 'spec_helper'

describe Saml::Elements::Conditions do

  let(:conditions) { build(:conditions) }

  describe "Optional fields" do
    [:not_before, :not_on_or_after, :audience_restriction].each do |field|
      it "should have the #{field} field" do
        conditions.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        conditions.send("#{field}=", nil)
        conditions.should be_valid
        conditions.send("#{field}=", "")
        conditions.should be_valid
      end
    end
  end

  describe "parse" do
    let(:conditions_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:conditions) { Saml::Elements::Conditions.parse(conditions_xml, :single => true) }

    it "should parse the StatusCode" do
      conditions.should be_a(Saml::Elements::Conditions)
    end

    it "should parse the not on or after attribute" do
      conditions.not_on_or_after.should == Time.parse("2011-08-31T08:51:05Z")
    end

    it "should parse the not before attribute" do
      conditions.not_before.should == Time.parse("2011-08-31T08:51:05Z")
    end

    it "should parse the AudienceRestriction" do
      conditions.audience_restriction.should be_a(Saml::Elements::AudienceRestriction)
    end
  end

  describe "initialize" do

    it "should set the audience restriction if audience is present" do
      condition = Saml::Elements::Conditions.new(:audience => "audience")
      condition.audience_restriction.audience.should == "audience"
    end

  end
end
