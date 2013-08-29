require "spec_helper"

describe Saml::ComplexTypes::AttributeType do
  let(:attribute_type) { FactoryGirl.build(:attribute_type_dummy) }

  describe "Required fields" do
    [:name].each do |field|
      it "should have the #{field} field" do
        attribute_type.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute_type.send("#{field}=", nil)
        attribute_type.should_not be_valid
      end
    end
  end

  describe "Optional fields" do
    [:format, :friendly_name].each do |field|
      it "should have the #{field} field" do
        attribute_type.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        attribute_type.send("#{field}=", nil)
        attribute_type.errors.entries.should == [] #be_valid
        attribute_type.send("#{field}=", "")
        attribute_type.errors.entries.should == [] #be_valid
      end
    end
  end

  describe "#parse" do
    let(:attribute_type_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:attribute_type) { Saml::Elements::Attribute.parse(attribute_type_xml, :single => true) }

    it "should create a Attribute" do
      attribute_type.should be_a(Saml::Elements::Attribute)
    end

  end
end
