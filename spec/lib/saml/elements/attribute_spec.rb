require 'spec_helper'

describe Saml::Elements::Attribute do
  let(:attribute) { FactoryGirl.build(:attribute) }

  describe "Required fields" do
    [:name].each do |field|
      it "should have the #{field} field" do
        attribute.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        attribute.send("#{field}=", nil)
        attribute.should_not be_valid
      end
    end
  end

  describe "#parse" do
    let(:attribute_xml) { File.read(File.join('spec','fixtures','artifact_response.xml')) }
    let(:attribute) { Saml::Elements::Attribute.parse(attribute_xml, :single => true) }
  
    it "should create a Attribute" do
      attribute.should be_a(Saml::Elements::Attribute)
    end
  
  end
end