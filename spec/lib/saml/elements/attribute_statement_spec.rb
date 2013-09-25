require 'spec_helper'

describe Saml::Elements::AttributeStatement do
  let(:attribute_statement) { FactoryGirl.build(:attribute_statement) }

  describe "#parse" do
    let(:attribute_statement_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:attribute_statement) { Saml::Elements::AttributeStatement.parse(attribute_statement_xml, :single => true) }

    it "should create a AttributeStatement" do
      attribute_statement.should be_a(Saml::Elements::AttributeStatement)
    end
  
    it "should parse attribute" do
      attribute_statement.attribute.first.should be_a(Saml::Elements::Attribute)
    end
  end
end
